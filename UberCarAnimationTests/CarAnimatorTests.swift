import XCTest
import CoreLocation
import GoogleMaps
// We need to make the main target's classes accessible to the test target.
// This is usually done by adding `@testable import UberCarAnimation`
// but that requires module stability or specific build settings.
// For simplicity in this environment, if direct import fails,
// we'd assume the necessary files from UberCarAnimation are compiled alongside tests
// or we'd have to manually include them (which is not ideal for unit testing).
// For now, I'll write it assuming `@testable import UberCarAnimation` works.

@testable import UberCarAnimation

// Mock GMSMarker for testing CarAnimator
class MockGMSMarker: GMSMarker {
    var mockPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var mockRotation: CLLocationDegrees = 0.0
    var mockGroundAnchor: CGPoint = CGPoint(x: 0.5, y: 0.5)
    var mockMap: GMSMapView?

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
    
    override var map: GMSMapView? {
        get { return mockMap }
        set { mockMap = newValue }
    }
    
    // To track layer changes for pause/resume testing
    var layerSpeed: Float = 1.0
    var layerTimeOffset: CFTimeInterval = 0.0
    
    override var layer: CALayer {
        let mockLayer = MockCALayer()
        // Allow tests to inspect these properties
        mockLayer.mockSpeed = self.layerSpeed
        mockLayer.mockTimeOffset = self.layerTimeOffset
        return mockLayer
    }
}

// Mock CALayer to inspect properties without real CoreAnimation
class MockCALayer: CALayer {
    var mockSpeed: Float = 1.0
    var mockTimeOffset: CFTimeInterval = 0.0

    override var speed: Float {
        get { return mockSpeed }
        set { mockSpeed = newValue }
    }

    override var timeOffset: CFTimeInterval {
        get { return mockTimeOffset }
        set { mockTimeOffset = newValue }
    }
    
    override func convertTime(_ t: CFTimeInterval, from l: CALayer?) -> CFTimeInterval {
        // For testing, we can return a fixed value or make it configurable if needed
        return CACurrentMediaTime()
    }
}


// Mock GMSMapView for testing CarAnimator
class MockGMSMapView: GMSMapView {
    var cameraTarget: CLLocationCoordinate2D?
    var cameraZoom: Float?
    
    override func animate(with cameraUpdate: GMSCameraUpdate) {
        // In a real test, you might inspect the cameraUpdate details.
        // For now, just acknowledge it was called.
        // This is a simplified mock. A more complex mock might parse GMSCameraUpdate.
    }
}

class CarAnimatorTests: XCTestCase {

    var carMarker: MockGMSMarker!
    var mapView: MockGMSMapView!
    var carAnimator: CarAnimator!

    override func setUp() {
        super.setUp()
        carMarker = MockGMSMarker()
        // Initialize with a default position
        carMarker.position = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco
        mapView = MockGMSMapView()
        
        // Ensure carMarker has a valid CALayer for pause/resume tests
        let mockLayer = MockCALayer()
        carMarker.setValue(mockLayer, forKey: "layer") // Using KVC if direct assignment is tricky with mocks

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
        XCTAssertTrue(carMarker === carAnimator.carMarker, "CarAnimator's carMarker should be the one it was initialized with.")
        XCTAssertTrue(mapView === carAnimator.mapView, "CarAnimator's mapView should be the one it was initialized with.")
    }

    func testAnimateToNewCoordinate() {
        let sourceCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let destinationCoordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437) // Los Angeles

        carAnimator.animate(from: sourceCoordinate, to: destinationCoordinate)

        // Check if marker's position is updated
        XCTAssertEqual(carMarker.position.latitude, destinationCoordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(carMarker.position.longitude, destinationCoordinate.longitude, accuracy: 0.0001)

        // Check rotation (bearing)
        // The actual bearing calculation is in CLLocationCoordinate2D extension,
        // but CarAnimator should set it.
        let expectedBearing = sourceCoordinate.bearing(to: destinationCoordinate)
        XCTAssertEqual(carMarker.rotation, expectedBearing, accuracy: 0.01, "Marker rotation should be updated.")
        
        // Check ground anchor
        XCTAssertEqual(carMarker.groundAnchor, CGPoint(x: 0.5, y: 0.5), "Marker ground anchor should be set to center.")
    }
    
    // Test pausing the animation layer
    func testPauseLayer() {
        guard let markerLayer = carMarker.layer as? MockCALayer else {
            XCTFail("Marker layer is not a MockCALayer instance.")
            return
        }
        // Simulate layer properties before pause
        markerLayer.mockSpeed = 1.0
        markerLayer.mockTimeOffset = 0.0
        
        carAnimator.pauseLayer(markerLayer)
        
        XCTAssertEqual(markerLayer.speed, 0.0, "Layer speed should be 0.0 after pausing.")
        XCTAssertNotEqual(markerLayer.timeOffset, 0.0, "Layer timeOffset should be set after pausing.")
    }
    
    // Test resuming the animation layer
    func testResumeLayer() {
         guard let markerLayer = carMarker.layer as? MockCALayer else {
            XCTFail("Marker layer is not a MockCALayer instance.")
            return
        }
        // Simulate layer properties as if paused
        markerLayer.mockSpeed = 0.0
        markerLayer.mockTimeOffset = 12345.6789 // Some paused time
        
        carAnimator.resumeLayer(markerLayer)
        
        XCTAssertEqual(markerLayer.speed, 1.0, "Layer speed should be 1.0 after resuming.")
        XCTAssertEqual(markerLayer.timeOffset, 0.0, "Layer timeOffset should be reset after resuming.")
        // We can't easily verify beginTime without deeper mocking of CACurrentMediaTime,
        // but speed and timeOffset are the primary indicators for resume.
    }
}

// Extend CarAnimator to access its properties for testing if they were private
extension CarAnimator {
    var carMarker: GMSMarker {
        return value(forKey: "_carMarker") as! GMSMarker
    }
    var mapView: GMSMapView {
        return value(forKey: "_mapView") as! GMSMapView
    }
}
