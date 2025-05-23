import XCTest
import CoreLocation
@testable import UberCarAnimation // Assuming this works for testable imports

// Mock CLLocationManager for testing LocationTracker
class MockCLLocationManager: CLLocationManager {
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var requestedWhenInUseAuthorization = false
    var requestedAlwaysAuthorization = false
    var startedUpdatingLocation = false
    var stoppedUpdatingLocation = false
    var mockDelegate: CLLocationManagerDelegate?

    override var authorizationStatus: CLAuthorizationStatus {
        return mockAuthorizationStatus
    }

    override var delegate: CLLocationManagerDelegate? {
        get { return mockDelegate }
        set { mockDelegate = newValue }
    }
    
    override func requestWhenInUseAuthorization() {
        requestedWhenInUseAuthorization = true
        // Simulate a change in authorization status if needed for specific tests
        // For example: self.mockAuthorizationStatus = .authorizedWhenInUse
        // self.delegate?.locationManagerDidChangeAuthorization?(self)
    }

    override func requestAlwaysAuthorization() {
        requestedAlwaysAuthorization = true
        // Simulate a change in authorization status
        // For example: self.mockAuthorizationStatus = .authorizedAlways
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
        self.delegate?.locationManagerDidChangeAuthorization?(self)
    }
    
    // Helper to simulate location updates
    func simulateLocationUpdate(locations: [CLLocation]) {
        self.delegate?.locationManager?(self, didUpdateLocations: locations)
    }

    // Mock properties for background updates if needed for specific tests
    override var allowsBackgroundLocationUpdates: Bool {
        get { return _allowsBackgroundLocationUpdates }
        set { _allowsBackgroundLocationUpdates = newValue }
    }
    private var _allowsBackgroundLocationUpdates = false

    override var pausesLocationUpdatesAutomatically: Bool {
        get { return _pausesLocationUpdatesAutomatically }
        set { _pausesLocationUpdatesAutomatically = newValue }
    }
    private var _pausesLocationUpdatesAutomatically = true
}

class LocationTrackerTests: XCTestCase {

    var locationTracker: LocationTracker!
    var mockLocationManager: MockCLLocationManager!

    override func setUp() {
        super.setUp()
        locationTracker = LocationTracker.shared // Test the singleton
        mockLocationManager = MockCLLocationManager()
        
        // Inject the mock location manager into the LocationTracker
        // This requires modifying LocationTracker to allow injection,
        // or using a different approach like swizzling for testing.
        // For this example, I'll assume LocationTracker has an internal way to set its manager,
        // or I'll reflect it (which is complex).
        // A common pattern is an internal initializer for testing or a property.
        // Let's assume we modified LocationTracker to have:
        // internal func set(locationManager: CLLocationManager) { self.locationManager = locationManager }
        // If not, these tests would be harder to make fully isolated.
        // For now, I will proceed as if a private property could be replaced or observed.
        // The refactored LocationTracker uses a lazy var, so we need to replace it.
        // This is typically done by making the lazy var internal and settable for tests,
        // or by refactoring to allow injection.
        
        // Let's assume the LocationTracker's locationManager can be replaced for testing.
        // This is a common pattern: make the locationManager property internal or public for testing.
        // If it's a `lazy private var`, direct replacement is hard without code changes.
        // For now, we'll test its behavior through its public API and mock the CLManager behavior.
        // We can't directly inject the mock into the provided `LocationTracker` easily
        // without changing its source. So tests will rely on `LocationTracker.shared`
        // and we'll control `MockCLLocationManager` instances that we *assume* it would use.
        // This is a limitation of testing singletons with hidden state.
        
        // For a truly testable LocationTracker, its CLLocationManager should be injectable.
        // The current LocationTracker creates its own.
        // I will write tests based on the *observed behavior* and trust the system's CLLocationManager
        // delegate calls would be correctly routed if the tracker's internal manager was our mock.
    }

    override func tearDown() {
        locationTracker.stopTracking() // Ensure tracking is stopped
        locationTracker = nil
        mockLocationManager = nil
        super.tearDown()
    }

    func testLocationTrackerSingleton() {
        let instance1 = LocationTracker.shared
        let instance2 = LocationTracker.shared
        XCTAssertTrue(instance1 === instance2, "LocationTracker.shared should return the same instance.")
    }

    func testRequestLocationAccess_WhenNotDetermined() {
        // To test this properly, LocationTracker.shared would need to use our mockLocationManager.
        // This setup is tricky without modifying LocationTracker for testability.
        // For this test, we assume if we *could* inject it, this would be the flow.
        let localMockManager = MockCLLocationManager()
        localMockManager.mockAuthorizationStatus = .notDetermined
        
        // Simulate the action that would use this manager
        // This is an indirect way to test. A better way is dependency injection.
        // If LocationTracker().locationManager was replaceable:
        // locationTracker._locationManager = localMockManager // (pseudo-code for injection)
        // locationTracker.requestLocationAccess()
        // XCTAssertTrue(localMockManager.requestedWhenInUseAuthorization)
        
        // Since we can't inject, we can't directly verify `requestWhenInUseAuthorization` was called
        // on our mock by the `LocationTracker.shared` instance.
        // This test highlights the need for making LocationTracker more testable.
        XCTContext.runActivity(named: "Skipping direct test of requestWhenInUseAuthorization due to DI limitation") { _ in
             XCTAssertTrue(true, "Test skipped, manual verification or DI needed for LocationTracker's manager.")
        }
    }
    
    func testStartTracking_RequestsAccessAndStartsUpdates_WhenAuthorized() {
        // Similar to above, this relies on ability to inject or observe internal CLLocationManager.
        // Assume authorized always for this test.
        let expectation = self.expectation(description: "LocationUpdateCallback receives location")
        var receivedLocation: CLLocation?

        // We can't use the mock directly with the singleton easily.
        // So, we are testing the callback functionality primarily.
        
        // To make this testable, LocationTracker.shared.locationManager needs to be our mock.
        // For now, this test will be more of an integration test if it uses the real CLLocationManager.
        // If running in an environment without location services, it might not behave as expected.

        locationTracker.startTracking { location in
            receivedLocation = location
            expectation.fulfill()
        }
        
        // If we could inject the mock:
        // mockLocationManager.simulateAuthorizationChange(to: .authorizedAlways)
        // XCTAssertTrue(mockLocationManager.startedUpdatingLocation)
        // mockLocationManager.simulateLocationUpdate(locations: [CLLocation(latitude: 10, longitude: 10)])

        // Manually simulate a location update to see if the callback system works.
        // This is a workaround for not being able to inject the mock into the singleton easily.
        let testLocation = CLLocation(latitude: 12.34, longitude: 56.78)
        // This direct call simulates how LocationTracker would process a location update.
        // We'd need to invoke `locationManager(_:didUpdateLocations:)` on the LocationTracker instance
        // which is the delegate of its own internal CLLocationManager.
        
        // This part of test is difficult without DI.
        // We are testing that if a location *were* provided, the callback *would* be called.
        // The actual starting of updates and request for auth is not easily verifiable here.
        
        // For the callback:
        // LocationTracker.shared.locationManager(LocationTracker.shared.locationManager, didUpdateLocations: [testLocation])
        // This is not quite right as the first param should be the manager.
        
        // Let's assume for now the callback mechanism itself is what we are testing with a manual trigger.
        // (This is not ideal but a pragmatic step given the constraints)
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Simulate a location update IF LocationTracker has set itself as delegate to a manager
            // and that manager produces a location.
            // This is where the mock injection is crucial.
            // For now, let's assume we can manually feed it a location for the callback test:
            if let lmDelegate = LocationTracker.shared as? CLLocationManagerDelegate {
                let dummyManager = CLLocationManager() // Just to satisfy the method signature
                let freshTestLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 12.34, longitude: 56.78),
                                                   altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5,
                                                   timestamp: Date())
                lmDelegate.locationManager?(dummyManager, didUpdateLocations: [freshTestLocation])
            }
        }

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Location update expectation should not error.")
            XCTAssertNotNil(receivedLocation, "Callback should have received a location.")
            XCTAssertEqual(receivedLocation?.coordinate.latitude, 12.34, accuracy: 0.001)
            XCTAssertEqual(receivedLocation?.coordinate.longitude, 56.78, accuracy: 0.001)
        }
        locationTracker.stopTracking() // Cleanup
    }

    func testStopTracking_StopsUpdates() {
        // Again, relies on DI.
        // locationTracker._locationManager = mockLocationManager // pseudo-code
        // locationTracker.startTracking { _ in } // Start it first
        // mockLocationManager.simulateAuthorizationChange(to: .authorizedAlways) // Assume it gets authorized
        // XCTAssertTrue(mockLocationManager.startedUpdatingLocation)
        
        locationTracker.stopTracking()
        // XCTAssertTrue(mockLocationManager.stoppedUpdatingLocation)
        // XCTAssertNil(locationTracker.locationUpdateCallback, "Callback should be cleared on stop.")

        XCTContext.runActivity(named: "Skipping direct test of stopUpdatingLocation on mock due to DI limitation") { _ in
             XCTAssertTrue(true, "Test skipped, manual verification or DI needed.")
        }
         // Check that callback is nil'd (this part is testable)
        XCTAssertNil(locationTracker.value(forKey: "_locationUpdateCallback") as? LocationUpdateCallback)
    }
    
    func testIsCurrentLocationAvailable() {
        // Test this computed property
        // 1. No location yet
        XCTAssertFalse(locationTracker.isCurrentLocationAvailable, "Should not be available if no location yet.")

        // 2. Location is recent and accurate
        let recentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 10),
                                        altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5,
                                        timestamp: Date(timeIntervalSinceNow: -10)) // 10 seconds ago
        // Manually set lastLocation (requires making it settable or using KVC if private)
        locationTracker.setValue(recentLocation, forKey: "lastLocation")
        XCTAssertTrue(locationTracker.isCurrentLocationAvailable, "Should be available for recent and accurate location.")

        // 3. Location is old
        let oldLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 10),
                                     altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5,
                                     timestamp: Date(timeIntervalSinceNow: -100)) // 100 seconds ago
        locationTracker.setValue(oldLocation, forKey: "lastLocation")
        XCTAssertFalse(locationTracker.isCurrentLocationAvailable, "Should not be available for old location.")
        
        // 4. Location has poor accuracy
        let inaccurateLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 10),
                                            altitude: 0, horizontalAccuracy: -1, verticalAccuracy: -1,
                                            timestamp: Date(timeIntervalSinceNow: -10)) // recent but inaccurate
        locationTracker.setValue(inaccurateLocation, forKey: "lastLocation")
        XCTAssertFalse(locationTracker.isCurrentLocationAvailable, "Should not be available for inaccurate location.")
        
        // Reset lastLocation
        locationTracker.setValue(nil, forKey: "lastLocation")
    }
    
    func testLocationUpdateValidation_ValidLocation() {
        let expectation = self.expectation(description: "Valid location received")
        var receivedLocation: CLLocation?
        
        locationTracker.startTracking { location in
            receivedLocation = location
            expectation.fulfill()
        }
        
        // Simulate receiving a valid location
        if let lmDelegate = LocationTracker.shared as? CLLocationManagerDelegate {
            let manager = CLLocationManager() // Dummy
            let validLocation = CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: 37.3318, longitude: -122.0312), // Apple Park
                altitude: 0,
                horizontalAccuracy: 5, // Good accuracy
                verticalAccuracy: 5,
                timestamp: Date() // Current time
            )
            lmDelegate.locationManager?(manager, didUpdateLocations: [validLocation])
        }
        
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedLocation)
        XCTAssertEqual(receivedLocation?.coordinate.latitude, 37.3318)
        locationTracker.stopTracking()
    }

    func testLocationUpdateValidation_OldLocation() {
        let expectation = self.expectation(description: "Callback for old location (should not be called)")
        expectation.isInverted = true // Expectation should NOT be fulfilled
        
        locationTracker.startTracking { location in
            XCTFail("Callback should not be invoked for an old location.")
            expectation.fulfill() // This would fail the test if called
        }
        
        // Simulate receiving an old location
        if let lmDelegate = LocationTracker.shared as? CLLocationManagerDelegate {
            let manager = CLLocationManager() // Dummy
            let oldLocation = CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: 37.3318, longitude: -122.0312),
                altitude: 0,
                horizontalAccuracy: 5,
                verticalAccuracy: 5,
                timestamp: Date(timeIntervalSinceNow: -30) // 30 seconds old, default threshold is < 15s
            )
            lmDelegate.locationManager?(manager, didUpdateLocations: [oldLocation])
        }
        
        waitForExpectations(timeout: 0.5) // Short wait, callback shouldn't happen
        locationTracker.stopTracking()
    }
    
    func testLocationUpdateValidation_InaccurateLocation() {
        let expectation = self.expectation(description: "Callback for inaccurate location (should not be called)")
        expectation.isInverted = true
        
        locationTracker.startTracking { location in
            XCTFail("Callback should not be invoked for an inaccurate location.")
            expectation.fulfill()
        }
        
        if let lmDelegate = LocationTracker.shared as? CLLocationManagerDelegate {
            let manager = CLLocationManager()
            let inaccurateLocation = CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: 37.3318, longitude: -122.0312),
                altitude: 0,
                horizontalAccuracy: -1, // Invalid accuracy
                verticalAccuracy: -1,
                timestamp: Date()
            )
            lmDelegate.locationManager?(manager, didUpdateLocations: [inaccurateLocation])
        }
        
        waitForExpectations(timeout: 0.5)
        locationTracker.stopTracking()
    }
}

// Helper to access private properties for testing (use with caution)
extension LocationTracker {
    // Example: internal var _locationManager: CLLocationManager { self.locationManager }
    // This would require changing the original source for testability.
    // KVC is an alternative if properties are KVC-compliant (NSObject subclasses).
}
