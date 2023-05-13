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
    var carMarker: GMSMarker
    var mapView: GMSMapView
    var carAnimator: CarAnimator
    
    init(currentLocationCoordinate: Binding<(CLLocationCoordinate2D?, CLLocationCoordinate2D?)> ) {
        GMSServices.provideAPIKey(ADD_YOUR_GOOGLE_API_KEY)
        let map = GMSMapView()
        mapView = map
        let marker = GMSMarker()
        carMarker = marker
        carAnimator = CarAnimator(carMarker: marker, mapView: map)

//        carMarker.map = mapView
//        carMarker.position = CLLocationCoordinate2D(
//            latitude: 30.6751951, longitude: 76.7401675)

        
        self._currentLocationCoordinate = currentLocationCoordinate
        carMarker.icon = UIImage(named: "car")

//        guard let currentLocationCoordinate else { return }
//        if let lastCoordinate = currentLocationCoordinate.wrappedValue.0,
//        let currentLocation = currentLocationCoordinate.wrappedValue.1 {
//            carAnimator.animate(from: lastCoordinate, to: currentLocation)
//        }

    }
    
    func makeUIView(context: Context) -> GMSMapView {
//        guard let currentLocationCoordinate else { fatalError() }

        let camera = GMSCameraPosition.camera(
            withLatitude: currentLocationCoordinate.0?.latitude ?? 30.6751951 ,
            longitude: currentLocationCoordinate.0?.longitude  ?? 76.7401675,
            zoom: 14.0)
        
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.drawPath(GMSMapView.pathString)

        mapView.mapStyle = mapStyle(UITraitCollection.current.userInterfaceStyle)
//        mapView.overrideUserInterfaceStyle =

        // Set the position of the carMarker here
        if let initialCoordinate = currentLocationCoordinate.0 {
            carMarker.position = initialCoordinate
        }
        

        return mapView
    }
        
    func updateUIView(_ mapView: GMSMapView, context: MapView.Context) {
//        guard let currentLocationCoordinate else { return }
        carMarker.map = nil

        if let lastCoordinate = currentLocationCoordinate.0,
        let currentLocation = currentLocationCoordinate.1 {
            carAnimator.animate(from: lastCoordinate, to: currentLocation)
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
