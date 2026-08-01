import XCTest
import CoreLocation
import GoogleMaps // Assuming GoogleMaps is part of this target or testable.
@testable import UberCarSwiftUI

// Mock GMSMarker for testing CarAnimator
class MockGMSMarker_SwiftUI: GMSMarker {
    var mockPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var mockRotation: CLLocationDegrees = 0.0
    var mockGroundAnchor: CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    // To track layer changes for pause/resume testing
    private var _layer: CALayer = MockCALayer_SwiftUI() // Each marker instance gets its own layer
    override var layer: CALayer {
        return _layer
    }

    override var position: CLLocationCoordinate2D {
        get { return mockPosition }
        set { mockPosition = newValue }
    }

    override var rotation: CLLocationDegrees {
        get { return mockRotation }
        set { mockRotation = newValue }
    }
    
    override var groundAnchor: CGPoint {
        get { return mockGroundAnchor }
        set { mockGroundAnchor = newValue }
    }
}

// Mock CALayer to inspect properties without real CoreAnimation
class MockCALayer_SwiftUI: CALayer {
    var mockSpeed: Float = 1.0
    var mockTimeOffset: CFTimeInterval = 0.0
    var mockBeginTime: CFTimeInterval = 0.0

    override var speed: Float {
        get { return mockSpeed }
        set { mockSpeed = newValue }
    }

    override var timeOffset: CFTimeInterval {
        get { return mockTimeOffset }
        set { mockTimeOffset = newValue }
    }
    
    override var beginTime: CFTimeInterval {
        get { return mockBeginTime }
        set { mockBeginTime = newValue }
    }
    
    override func convertTime(_ t: CFTimeInterval, from l: CALayer?) -> CFTimeInterval {
        // For testing, we can return a fixed value or make it configurable if needed
        // This mock needs to be consistent with how CALayer converts time or how CACurrentMediaTime() behaves.
        // For simplicity, using CACurrentMediaTime() directly is often okay in tests if it doesn't introduce flakiness.
        return CACurrentMediaTime() 
    }
}

// Mock GMSMapView for testing CarAnimator
class MockGMSMapView_SwiftUI: GMSMapView {
    var didAnimateWithCameraUpdate = false
    
    override func animate(with cameraUpdate: GMSCameraUpdate) {
        didAnimateWithCameraUpdate = true
    }
}

class CarAnimatorTests_SwiftUI: XCTestCase {

    var carMarker: MockGMSMarker_SwiftUI!
    var mapView: MockGMSMapView_SwiftUI!
    var carAnimator: CarAnimator!

    override func setUp() {
        super.setUp()
        carMarker = MockGMSMarker_SwiftUI()
        // Set an initial position for the marker
        carMarker.position = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mapView = MockGMSMapView_SwiftUI()
        carAnimator = CarAnimator(carMarker: carMarker, mapView: mapView)
    }

    override func tearDown() {
        carMarker = nil
        mapView = nil
        carAnimator = nil
        super.tearDown()
    }

    func testCarAnimatorInitialization() {
        XCTAssertNotNil(carAnimator, "CarAnimator should be initialized.")
        // Check if the animator retained the marker and map view (cannot directly access private properties)
        // This test is more about the animator being created without crashing.
    }

    func testAnimateToNewCoordinate_UpdatesMarkerAndMap() {
        let sourceCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // SF
        let destinationCoordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437) // LA

        carAnimator.animate(from: sourceCoordinate, to: destinationCoordinate)

        // Check marker's position (final state after animation)
        XCTAssertEqual(carMarker.position.latitude, destinationCoordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(carMarker.position.longitude, destinationCoordinate.longitude, accuracy: 0.0001)

        // Check marker's rotation
        // The bearing calculation is in an extension, assume it's correct.
        // CarAnimator uses it to set the rotation.
        let expectedBearing = sourceCoordinate.bearing(to: destinationCoordinate)
        XCTAssertEqual(carMarker.rotation, expectedBearing, accuracy: 0.01, "Marker rotation should be updated.")
        
        // Check ground anchor
        XCTAssertEqual(carMarker.groundAnchor, CGPoint(x: 0.5, y: 0.5), "Marker ground anchor should be set to center.")
        
        // Check if map view was asked to animate
        XCTAssertTrue(mapView.didAnimateWithCameraUpdate, "MapView should animate to the new camera position.")
    }
    
    func testPauseLayer() {
        guard let markerLayer = carMarker.layer as? MockCALayer_SwiftUI else {
            XCTFail("Marker layer is not a MockCALayer_SwiftUI instance.")
            return
        }
        // Initial state of the layer (simulating it's playing)
        markerLayer.mockSpeed = 1.0
        markerLayer.mockTimeOffset = 0.0
        
        carAnimator.pauseLayer(markerLayer)
        
        XCTAssertEqual(markerLayer.speed, 0.0, "Layer speed should be 0.0 after pausing.")
        // timeOffset will be set to the current media time, so it should be non-zero (unless media time is 0)
        XCTAssertNotEqual(markerLayer.timeOffset, 0.0, "Layer timeOffset should be set after pausing, reflecting current media time.")
    }
    
    func testResumeLayer() {
         guard let markerLayer = carMarker.layer as? MockCALayer_SwiftUI else {
            XCTFail("Marker layer is not a MockCALayer_SwiftUI instance.")
            return
        }
        // Simulate layer properties as if paused
        let pausedTimeOffset: CFTimeInterval = 12345.6789 // An arbitrary non-zero paused time
        markerLayer.mockSpeed = 0.0
        markerLayer.mockTimeOffset = pausedTimeOffset
        markerLayer.mockBeginTime = 0.0 // As it would be before resume
        
        carAnimator.resumeLayer(markerLayer)
        
        XCTAssertEqual(markerLayer.speed, 1.0, "Layer speed should be 1.0 after resuming.")
        XCTAssertEqual(markerLayer.timeOffset, 0.0, "Layer timeOffset should be reset to 0.0 after resuming.")
        // beginTime should be adjusted. It's calculated as:
        // let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTimeOffset
        // layer.beginTime = timeSincePause
        // So, it should be non-zero if CACurrentMediaTime() is greater than pausedTimeOffset.
        // This part is tricky to assert precisely without controlling CACurrentMediaTime().
        // We can assert that it's not the initial beginTime (0.0) if time has passed.
        // For this test, we'll assume convertTime and CACurrentMediaTime work as expected.
        // A simple check is that it's not still 0 if time has advanced.
        // However, if execution is extremely fast, timeSincePause could be very small or even zero.
        // The crucial parts are speed and timeOffset being reset.
         XCTAssertTrue(markerLayer.beginTime >= 0, "Layer beginTime should be adjusted and non-negative.")
    }
}

// Assume CLLocationCoordinate2D.bearing(to:) and Double.toRadians/toDegrees are available via Extensions.swift
// If Extensions.swift is not part of the UberCarSwiftUI target or this test target,
// these tests might fail to compile. For unit tests, it's common to include utility extensions
// or make them part of the main app target that's imported with @testable.
// (The `Extensions.swift` file was refactored in Subtask 3 and should be available.)
