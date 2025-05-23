import XCTest
import CoreLocation
import Combine
@testable import CarAnimationMapKitSwiftui // This assumes the module name is CarAnimationMapKitSwiftui

// Mock CLLocationManager for testing MapViewModel
class MockCLLocationManager: CLLocationManager {
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var requestedWhenInUseAuthorization = false
    var startedUpdatingLocation = false
    var stoppedUpdatingLocation = false
    
    // Storing the delegate instead of just using the superclass's delegate
    // to ensure our mock methods are called.
    private var _delegate: CLLocationManagerDelegate?
    override var delegate: CLLocationManagerDelegate? {
        get { return _delegate }
        set { _delegate = newValue }
    }

    override var authorizationStatus: CLAuthorizationStatus {
        return mockAuthorizationStatus
    }
    
    override func requestWhenInUseAuthorization() {
        requestedWhenInUseAuthorization = true
        // Simulate a change for testing if needed, e.g.,
        // self.mockAuthorizationStatus = .denied
        // self.delegate?.locationManagerDidChangeAuthorization?(self)
    }

    override func startUpdatingLocation() {
        startedUpdatingLocation = true
        stoppedUpdatingLocation = false
    }

    override func stopUpdatingLocation() {
        stoppedUpdatingLocation = true
        startedUpdatingLocation = false
    }
    
    // Helper to simulate authorization change by tests
    func simulateAuthorizationChange(to status: CLAuthorizationStatus) {
        self.mockAuthorizationStatus = status
        // Use the stored delegate
        self.delegate?.locationManagerDidChangeAuthorization?(self)
    }
    
    // Helper to simulate location updates
    func simulateLocationUpdate(locations: [CLLocation]) {
        // Use the stored delegate
        self.delegate?.locationManager?(self, didUpdateLocations: locations)
    }

    // Mock other properties if needed by MapViewModel's configuration
    override var desiredAccuracy: CLLocationAccuracy {
        get { _desiredAccuracy }
        set { _desiredAccuracy = newValue }
    }
    private var _desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest

    override var distanceFilter: CLLocationDistance {
        get { _distanceFilter }
        set { _distanceFilter = newValue }
    }
    private var _distanceFilter: CLLocationDistance = kCLDistanceFilterNone

    override var activityType: CLActivityType {
        get { _activityType }
        set { _activityType = newValue }
    }
    private var _activityType: CLActivityType = .other
}


class MapViewModelTests: XCTestCase {

    var viewModel: MapViewModel!
    var mockLocationManager: MockCLLocationManager!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockLocationManager = MockCLLocationManager()
        // Use the initializer to inject the mock location manager
        viewModel = MapViewModel(locationManager: mockLocationManager)
        
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockLocationManager = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertEqual(viewModel.currentCoordinate.latitude, 0, "Initial latitude should be 0.")
        XCTAssertEqual(viewModel.currentCoordinate.longitude, 0, "Initial longitude should be 0.")
        XCTAssertEqual(viewModel.heading, 0, "Initial heading should be 0.")
        XCTAssertFalse(viewModel.isLocationServicesEnabled, "Location services should be initially disabled in ViewModel state.")
        // Check if CLLocationManager configuration was called on the mock
        XCTAssertEqual(mockLocationManager.desiredAccuracy, kCLLocationAccuracyBestForNavigation, "Desired accuracy should be set on the mock.")
        XCTAssertEqual(mockLocationManager.distanceFilter, 10, "Distance filter should be set on the mock.") // As per MapViewModel's Config
        XCTAssertEqual(mockLocationManager.activityType, .automotiveNavigation, "Activity type should be set on the mock.")
    }

    func testStartLocationUpdates_WhenNotDetermined() {
        mockLocationManager.mockAuthorizationStatus = .notDetermined
        viewModel.startLocationUpdates()
        XCTAssertTrue(mockLocationManager.requestedWhenInUseAuthorization, "Should request WhenInUse authorization if status is notDetermined.")
        XCTAssertFalse(mockLocationManager.startedUpdatingLocation, "Should not start updating location if status is notDetermined yet.")
    }

    func testStartLocationUpdates_WhenDenied() {
        let expectation = XCTestExpectation(description: "isLocationServicesEnabled becomes false")
        viewModel.$isLocationServicesEnabled.sink { enabled in
            if !enabled { expectation.fulfill() }
        }.store(in: &cancellables)

        mockLocationManager.mockAuthorizationStatus = .denied
        viewModel.startLocationUpdates()
        
        XCTAssertFalse(mockLocationManager.startedUpdatingLocation, "Should not start updating location if status is denied.")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLocationServicesEnabled, "isLocationServicesEnabled should be false when denied.")
    }

    func testStartLocationUpdates_WhenAuthorized() {
        let expectation = XCTestExpectation(description: "isLocationServicesEnabled becomes true")
        viewModel.$isLocationServicesEnabled.sink { enabled in
            if enabled { expectation.fulfill() }
        }.store(in: &cancellables)

        mockLocationManager.mockAuthorizationStatus = .authorizedWhenInUse
        viewModel.startLocationUpdates()
        
        XCTAssertTrue(mockLocationManager.startedUpdatingLocation, "Should start updating location if status is authorized.")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.isLocationServicesEnabled, "isLocationServicesEnabled should be true when authorized.")
    }
    
    func testStopLocationUpdates() {
        viewModel.startLocationUpdates() // Ensure it's started or attempted to start
        viewModel.stopLocationUpdates()
        XCTAssertTrue(mockLocationManager.stoppedUpdatingLocation, "Should stop updating location.")
    }

    func testLocationManagerDidChangeAuthorization_ToAuthorized() {
        let expectation = XCTestExpectation(description: "isLocationServicesEnabled becomes true on auth change")
         viewModel.$isLocationServicesEnabled.sink { enabled in
            if enabled { expectation.fulfill() }
        }.store(in: &cancellables)

        mockLocationManager.simulateAuthorizationChange(to: .authorizedAlways)
        
        XCTAssertTrue(mockLocationManager.startedUpdatingLocation, "Should start location updates when authorization changes to authorized.")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.isLocationServicesEnabled, "isLocationServicesEnabled should be true.")
    }

    func testLocationManagerDidChangeAuthorization_ToDenied() {
        let expectation = XCTestExpectation(description: "isLocationServicesEnabled becomes false on auth change to denied")
        // Start with true state by directly setting the published property for the test's premise
        viewModel.isLocationServicesEnabled = true
        
        viewModel.$isLocationServicesEnabled.dropFirst().sink { enabled in // dropFirst to avoid capturing the initial set value
            if !enabled { expectation.fulfill() }
        }.store(in: &cancellables)

        mockLocationManager.simulateAuthorizationChange(to: .denied)
        
        XCTAssertFalse(mockLocationManager.startedUpdatingLocation, "Should not start (or should stop if already started) location updates when authorization changes to denied.")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLocationServicesEnabled, "isLocationServicesEnabled should be false.")
    }
    
    func testDidUpdateLocations_ValidLocation() {
        let coord1Lat = 37.7749
        let coord1Lon = -122.4194
        let coord2Lat = 37.3318 // Apple Park
        let coord2Lon = -122.0312

        let location1 = CLLocation(latitude: coord1Lat, longitude: coord1Lon)
        let location2Timestamp = Date()
        let location2 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: coord2Lat, longitude: coord2Lon),
                                   altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: location2Timestamp)

        let headingExp = XCTestExpectation(description: "Heading gets updated")
        let coordinateExp = XCTestExpectation(description: "Coordinate gets updated")

        viewModel.currentCoordinate = location1.coordinate // Set an initial previous coordinate
        
        viewModel.$heading.dropFirst().sink { newHeading in
            XCTAssertNotEqual(newHeading, 0.0, "Heading should change from initial 0.0")
            headingExp.fulfill()
        }.store(in: &cancellables)
        
        viewModel.$currentCoordinate.dropFirst().sink { newCoord in
            XCTAssertEqual(newCoord.latitude, coord2Lat, accuracy: 0.0001)
            XCTAssertEqual(newCoord.longitude, coord2Lon, accuracy: 0.0001)
            coordinateExp.fulfill()
        }.store(in: &cancellables)

        mockLocationManager.simulateLocationUpdate(locations: [location2])
        
        wait(for: [headingExp, coordinateExp], timeout: 1.0)
    }

    func testDidUpdateLocations_FiltersOldLocation() {
        let oldLocationTimestamp = Date(timeIntervalSinceNow: -30) // 30 seconds old
        let oldLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // LA
                                   altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: oldLocationTimestamp)
        
        let coordinateExp = XCTestExpectation(description: "currentCoordinate should not update with old location")
        coordinateExp.isInverted = true // Verify it's NOT fulfilled

        viewModel.$currentCoordinate.dropFirst().sink { _ in
            coordinateExp.fulfill() // This should not be called
        }.store(in: &cancellables)
        
        mockLocationManager.simulateLocationUpdate(locations: [oldLocation])
        
        wait(for: [coordinateExp], timeout: 0.5)
    }
    
    func testDidUpdateLocations_FiltersInaccurateLocation() {
        let inaccurateLocationTimestamp = Date()
        let inaccurateLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // LA
                                            altitude: 0, horizontalAccuracy: 50, verticalAccuracy: 50, // Too inaccurate (threshold is < 20m)
                                            timestamp: inaccurateLocationTimestamp)
        
        let coordinateExp = XCTestExpectation(description: "currentCoordinate should not update with inaccurate location")
        coordinateExp.isInverted = true

        viewModel.$currentCoordinate.dropFirst().sink { _ in
            coordinateExp.fulfill()
        }.store(in: &cancellables)
        
        mockLocationManager.simulateLocationUpdate(locations: [inaccurateLocation])
        
        wait(for: [coordinateExp], timeout: 0.5)
    }
    
    func testDidFailWithError() {
        let expectation = XCTestExpectation(description: "isLocationServicesEnabled becomes false on error")
        viewModel.isLocationServicesEnabled = true // Start with true state by directly setting the published property

        viewModel.$isLocationServicesEnabled.dropFirst().sink { enabled in // dropFirst to avoid capturing the initial set value
            if !enabled { expectation.fulfill() }
        }.store(in: &cancellables)
        
        let testError = NSError(domain: "TestError", code: 1, userInfo: nil)
        // Manually call delegate method
        (viewModel as CLLocationManagerDelegate).locationManager?(mockLocationManager, didFailWithError: testError)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLocationServicesEnabled, "isLocationServicesEnabled should be false after error.")
    }
}

// No need for KVC extension on MapViewModel anymore as DI is used.

// Extension for CLLocationCoordinate2D Equatable for XCTAssertEqual with accuracy
extension CLLocationCoordinate2D {
    static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
