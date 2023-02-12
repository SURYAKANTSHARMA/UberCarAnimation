//
//  MapView.swift
//  UberCarSwiftUI
//
//  Created by Surya on 12/02/23.
//

import SwiftUI
import GoogleMaps

struct MapView: UIViewRepresentable {
    let centerCoordinate: CLLocationCoordinate2D?
    
    func makeUIView(context: Context) -> GMSMapView {
        GMSServices.provideAPIKey(ADD_YOUR_GOOGLE_API_KEY)
        let camera = GMSCameraPosition.camera(
            withLatitude: centerCoordinate?.latitude ?? 30.6751951,
            longitude: centerCoordinate?.longitude ?? 76.7401675,
            zoom: 14.0)
        
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.drawPath(GMSMapView.pathString)

        mapView.mapStyle = mapStyle(UITraitCollection.current.userInterfaceStyle)
//        mapView.overrideUserInterfaceStyle =

        return mapView
    }
        
    
    private func mapStyle(_ style: UIUserInterfaceStyle) -> GMSMapStyle? {
        let styleResourceName = "mapStyle\(style.rawValue)"
            guard let styleURL = Bundle.main.url(forResource: styleResourceName, withExtension: "json") else { return nil }
            let mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
            return mapStyle
    }
        
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Updating the map view
    }
}
