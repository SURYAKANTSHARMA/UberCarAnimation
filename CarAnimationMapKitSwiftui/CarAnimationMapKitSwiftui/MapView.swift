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

class CarAnnotationView: MKAnnotationView {
    static let identifier = "CarAnnotationView"

    override var annotation: MKAnnotation? {
        willSet {
            guard let _ = newValue else { return }

            image = UIImage(named: "car")
        }
    }
}
