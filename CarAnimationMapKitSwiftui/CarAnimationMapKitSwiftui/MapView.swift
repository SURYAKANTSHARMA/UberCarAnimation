//
//  MapView.swift
//  CarAnimationMapKitSwiftui
//
//  Created by Suryakant Sharma on 03/08/24.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D
    var routeCoordinates: [CLLocationCoordinate2D]
    @Binding var mapView: MKMapView

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        uiView.setRegion(region, animated: true)
        
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        uiView.addOverlay(polyline)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: CarAnnotationView.identifier)
            
            if annotationView == nil {
                annotationView = CarAnnotationView(annotation: annotation, reuseIdentifier: CarAnnotationView.identifier)
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
}

import MapKit

class CarAnnotationView: MKAnnotationView {
    static let identifier = "CarAnnotationView"

    override var annotation: MKAnnotation? {
        willSet {
            guard let _ = newValue else { return }
            image = UIImage(named: "car") // Set car image
        }
    }
    
    // MARK: - Animate Car Movement
    func animateCarMovement(from oldCoordinate: CLLocationCoordinate2D, to newCoordinate: CLLocationCoordinate2D) {
        let bearing = calculateBearing(from: oldCoordinate, to: newCoordinate) // Calculate angle
        
        // Animate the car's movement and rotation
        UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseInOut], animations: {
            // Rotate the car to the correct angle
            self.transform = CGAffineTransform(rotationAngle: CGFloat(bearing))
            
            // Move the car to the new position on the map
            if let mapView = self.superview as? MKMapView {
                self.center = mapView.convert(newCoordinate, toPointTo: mapView)
            }
        })
    }

    // MARK: - Calculate Bearing (Angle)
    private func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CGFloat {
        let fromLat = degreesToRadians(degrees: from.latitude)
        let fromLng = degreesToRadians(degrees: from.longitude)
        let toLat = degreesToRadians(degrees: to.latitude)
        let toLng = degreesToRadians(degrees: to.longitude)
        
        let deltaLng = toLng - fromLng
        let y = sin(deltaLng) * cos(toLat)
        let x = cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(deltaLng)
        let radiansBearing = atan2(y, x)
        
        return CGFloat(radiansBearing)
    }

    // Helper function to convert degrees to radians
    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180
    }
}
