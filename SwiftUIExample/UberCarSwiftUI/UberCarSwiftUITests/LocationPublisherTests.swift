import XCTest
import CoreLocation
import Combine
@testable import UberCarSwiftUI

// Mock CLLocationManager for testing LocationPublisher
class MockCLLocationManager: CLLocationManager {
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var requestedWhenInUseAuthorization = false
    var startedUpdatingLocation = false
    var stoppedUpdatingLocation = false
    
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
    }

    override func startUpdatingLocation() {
        startedUpdatingLocation = true
        stoppedUpdatingLocation = false
    }

    override func stopUpdatingLocation() {
        stoppedUpdatingLocation = true
        startedUpdatingLocation = false
    }
    
    // Helpers to simulate delegate calls
    func simulateAuthorizationChange(to status: CLAuthorizationStatus) {
        self.mockAuthorizationStatus = status
        self.delegate?.locationManagerDidChangeAuthorization?(self)
    }
    
    func simulateDidUpdateLocations(locations: [CLLocation]) {
        self.delegate?.locationManager?(self, didUpdateLocations: locations)
    }
    
    func simulateDidFailWithError(error: Error) {
        self.delegate?.locationManager?(self, didFailWithError: error)
    }

    // Mocked properties for configuration
    override var activityType: CLActivityType { didSet {} }
    override var distanceFilter: CLLocationDistance { didSet {} }
    override var desiredAccuracy: CLLocationAccuracy { didSet {} }

    override init() {
        super.init()
        // Initialize settable properties to default values to avoid issues if accessed before set
        self.activityType = .other
        self.distanceFilter = kCLDistanceFilterNone
        self.desiredAccuracy = kCLLocationAccuracyBest
    }
}

class LocationPublisherTests: XCTestCase {

    var locationPublisher: LocationPublisher!
    var mockLocationManager: MockCLLocationManager!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockLocationManager = MockCLLocationManager()
        locationPublisher = LocationPublisher(locationManager: mockLocationManager)
        cancellables = []
    }

    override func tearDown() {
        locationPublisher = nil
        mockLocationManager = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialization_ConfiguresLocationManager() {
        XCTAssertTrue(mockLocationManager.delegate === locationPublisher, "LocationManager's delegate should be the LocationPublisher instance.")
        XCTAssertEqual(mockLocationManager.activityType, .automotiveNavigation)
        XCTAssertEqual(mockLocationManager.distanceFilter, 10) // From LocationPublisher.Config
        XCTAssertEqual(mockLocationManager.desiredAccuracy, kCLLocationAccuracyBestForNavigation) // From LocationPublisher.Config
    }

    func testStart_WhenNotDetermined_RequestsAuth() {
        mockLocationManager.mockAuthorizationStatus = .notDetermined
        locationPublisher.start()
        XCTAssertTrue(mockLocationManager.requestedWhenInUseAuthorization)
        XCTAssertFalse(mockLocationManager.startedUpdatingLocation)
    }
    
    func testStart_WhenAuthorized_StartsUpdates() {
        mockLocationManager.mockAuthorizationStatus = .authorizedWhenInUse
        locationPublisher.start()
        XCTAssertTrue(mockLocationManager.startedUpdatingLocation)
    }

    func testStart_WhenDenied_DoesNotStartUpdates() {
        mockLocationManager.mockAuthorizationStatus = .denied
        locationPublisher.start()
        XCTAssertFalse(mockLocationManager.startedUpdatingLocation)
    }
    
    func testStop_StopsUpdates() {
        locationPublisher.start() // Ensure it's started or attempted
        locationPublisher.stop()
        XCTAssertTrue(mockLocationManager.stoppedUpdatingLocation)
    }

    func testLocationManagerDidChangeAuthorization_ToAuthorized_StartsUpdates() {
        mockLocationManager.simulateAuthorizationChange(to: .authorizedAlways)
        XCTAssertTrue(mockLocationManager.startedUpdatingLocation)
    }
    
    func testLocationManagerDidChangeAuthorization_ToDenied_StopsUpdates() {
        // Start it first, assuming it was authorized
        mockLocationManager.mockAuthorizationStatus = .authorizedWhenInUse
        locationPublisher.start()
        XCTAssertTrue(mockLocationManager.startedUpdatingLocation) // Pre-condition

        // Now simulate denial
        mockLocationManager.simulateAuthorizationChange(to: .denied)
        XCTAssertTrue(mockLocationManager.stoppedUpdatingLocation)
    }

    func testDidUpdateLocations_PublishesValidLocation() {
        let expectation = XCTestExpectation(description: "Valid location is published")
        let validLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0),
                                       altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())

        locationPublisher.locationPublisher
            .sink { location in
                XCTAssertEqual(location.coordinate.latitude, validLocation.coordinate.latitude)
                XCTAssertEqual(location.coordinate.longitude, validLocation.coordinate.longitude)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockLocationManager.simulateDidUpdateLocations(locations: [validLocation])
        wait(for: [expectation], timeout: 1.0)
    }

    func testDidUpdateLocations_FiltersOldLocation() {
        let expectation = XCTestExpectation(description: "Old location is filtered")
        expectation.isInverted = true // Should NOT be fulfilled
        
        let oldLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0),
                                     altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5,
                                     timestamp: Date(timeIntervalSinceNow: -30)) // 30s old

        locationPublisher.locationPublisher
            .sink { _ in expectation.fulfill() } // Fails if called
            .store(in: &cancellables)
        
        mockLocationManager.simulateDidUpdateLocations(locations: [oldLocation])
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testDidUpdateLocations_FiltersInaccurateLocation() {
        let expectation = XCTestExpectation(description: "Inaccurate location is filtered")
        expectation.isInverted = true // Should NOT be fulfilled

        let inaccurateLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0),
                                            altitude: 0, horizontalAccuracy: 50, verticalAccuracy: 50, // accuracy > 20m threshold
                                            timestamp: Date())

        locationPublisher.locationPublisher
            .sink { _ in expectation.fulfill() } // Fails if called
            .store(in: &cancellables)
        
        mockLocationManager.simulateDidUpdateLocations(locations: [inaccurateLocation])
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testDidFailWithError_PrintsError() {
        // This test mainly checks that the delegate method is called and doesn't crash.
        // The current implementation only prints the error.
        // If error publishing was added, this test would subscribe to that.
        let testError = NSError(domain: "TestLocationError", code: 123, userInfo: nil)
        mockLocationManager.simulateDidFailWithError(error: testError)
        // No XCTAssert here as the method just prints. Test passes if no crash.
        // To make it more robust, you could capture stdout or add an error publisher.
        XCTAssertTrue(true, "didFailWithError was called, check console for printed error.")
    }
}
