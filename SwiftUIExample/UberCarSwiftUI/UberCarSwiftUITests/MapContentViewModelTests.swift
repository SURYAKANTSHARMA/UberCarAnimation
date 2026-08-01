import XCTest
import CoreLocation
import Combine
@testable import UberCarSwiftUI // Assumes module name is UberCarSwiftUI

// Mock LocationPublishing provider for testing MapContentViewModel
class MockLocationProvider: LocationPublishing {
    var locationPublisherSubject = PassthroughSubject<CLLocation, Never>()
    var locationPublisher: AnyPublisher<CLLocation, Never> {
        locationPublisherSubject.eraseToAnyPublisher()
    }
    
    var startedUpdates = false
    var stoppedUpdates = false

    func start() {
        startedUpdates = true
    }

    func stop() {
        stoppedUpdates = true
    }
}

class MapContentViewModelTests: XCTestCase {

    var viewModel: MapContentViewModel!
    var mockLocationProvider: MockLocationProvider!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockLocationProvider = MockLocationProvider()
        viewModel = MapContentViewModel(locationProvider: mockLocationProvider)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockLocationProvider = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertNil(viewModel.locationPair.previous, "Initial previous location should be nil.")
        XCTAssertNil(viewModel.locationPair.current, "Initial current location should be nil.")
    }

    func testStartLocationUpdates_CallsProviderStart() {
        viewModel.startLocationUpdates()
        XCTAssertTrue(mockLocationProvider.startedUpdates, "startLocationUpdates should call start on its locationProvider.")
    }

    func testStopLocationUpdates_CallsProviderStop() {
        viewModel.stopLocationUpdates()
        XCTAssertTrue(mockLocationProvider.stoppedUpdates, "stopLocationUpdates should call stop on its locationProvider.")
    }

    func testLocationUpdates_ProcessLocationPairCorrectly() {
        let expectation = XCTestExpectation(description: "locationPair is updated with previous and current locations")
        
        let location1 = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
        let location2 = CLLocation(latitude: 34.0522, longitude: -118.2437) // Los Angeles
        let location3 = CLLocation(latitude: 40.7128, longitude: -74.0060)  // New York

        var updateCount = 0
        
        viewModel.$locationPair
            .dropFirst() // Ignore initial (nil, nil)
            .sink { pair in
                updateCount += 1
                switch updateCount {
                case 1: // First location published by provider
                    XCTAssertNil(pair.previous, "First update: previous should be nil.")
                    XCTAssertEqual(pair.current?.latitude, location1.coordinate.latitude)
                    XCTAssertEqual(pair.current?.longitude, location1.coordinate.longitude)
                case 2: // Second location published
                    XCTAssertEqual(pair.previous?.latitude, location1.coordinate.latitude)
                    XCTAssertEqual(pair.previous?.longitude, location1.coordinate.longitude)
                    XCTAssertEqual(pair.current?.latitude, location2.coordinate.latitude)
                    XCTAssertEqual(pair.current?.longitude, location2.coordinate.longitude)
                case 3: // Third location published
                    XCTAssertEqual(pair.previous?.latitude, location2.coordinate.latitude)
                    XCTAssertEqual(pair.previous?.longitude, location2.coordinate.longitude)
                    XCTAssertEqual(pair.current?.latitude, location3.coordinate.latitude)
                    XCTAssertEqual(pair.current?.longitude, location3.coordinate.longitude)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected number of updates.")
                }
            }
            .store(in: &cancellables)

        // Simulate location updates from the provider
        mockLocationProvider.locationPublisherSubject.send(location1)
        mockLocationProvider.locationPublisherSubject.send(location2)
        mockLocationProvider.locationPublisherSubject.send(location3)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testLocationUpdates_InitialLocation() {
        let expectation = XCTestExpectation(description: "locationPair is updated with current location, previous is nil")
        
        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)

        viewModel.$locationPair
            .dropFirst()
            .sink { pair in
                XCTAssertNil(pair.previous, "For the very first location, previous should be nil.")
                XCTAssertEqual(pair.current?.latitude, initialLocation.coordinate.latitude)
                XCTAssertEqual(pair.current?.longitude, initialLocation.coordinate.longitude)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockLocationProvider.locationPublisherSubject.send(initialLocation)
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// Helper for comparing CLLocationCoordinate2D for XCTAssertEqual (optional, if not using accuracy version)
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
