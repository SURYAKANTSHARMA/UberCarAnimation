//
//  MapView.swift
//  UberCarSwiftUI
//
//  Created by Surya on 12/02/23.
//

import SwiftUI
import GoogleMaps

struct MapView: UIViewRepresentable {
    @Binding var currentLocationCoordinate: (CLLocationCoordinate2D?, CLLocationCoordinate2D?)
    @State private var carMarker: GMSMarker = GMSMarker()
    @State private var mapView: GMSMapView = GMSMapView()
    @State var carAnimator: CarAnimator!

    init(currentLocationCoordinate: Binding<(CLLocationCoordinate2D?, CLLocationCoordinate2D?)>) {

            self._currentLocationCoordinate = currentLocationCoordinate
                        
            // Configure carMarker
            carMarker.icon = UIImage(named: "car")
        }
    
    func makeUIView(context: Context) -> GMSMapView {

        let camera = GMSCameraPosition.camera(
            withLatitude: currentLocationCoordinate.0?.latitude ?? 30.6751951 ,
            longitude: currentLocationCoordinate.0?.longitude  ?? 76.7401675,
            zoom: 14.0)
        
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.drawPath(GMSMapView.pathString)

        mapView.mapStyle = mapStyle(UITraitCollection.current.userInterfaceStyle)

        // Set the position of the carMarker here
        if let initialCoordinate = currentLocationCoordinate.0 {
            carMarker.position = initialCoordinate
        }
        

        return mapView
    }
        
    func updateUIView(_ mapView: GMSMapView, context: MapView.Context) {
        if carAnimator == nil {
            DispatchQueue.main.async {
                carAnimator = CarAnimator(carMarker: carMarker, mapView: mapView)
            }
        }
        if let lastCoordinate = currentLocationCoordinate.0,
        let currentLocation = currentLocationCoordinate.1 {
            carAnimator?.animate(from: lastCoordinate, to: currentLocation)
            if carMarker.map == nil {
                carMarker.map = mapView
            }
            // Add the car marker to the map

        }

    }

    
    private func mapStyle(_ style: UIUserInterfaceStyle) -> GMSMapStyle? {
        let styleResourceName = "mapStyle\(style.rawValue)"
            guard let styleURL = Bundle.main.url(forResource: styleResourceName, withExtension: "json") else { return nil }
            let mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
            return mapStyle
    }
        
}


class LastUpdatedCoordinateWrapper {
    var coordinate: CLLocationCoordinate2D?
    
    init(coordinate: CLLocationCoordinate2D?) {
        self.coordinate = coordinate
    }
}
