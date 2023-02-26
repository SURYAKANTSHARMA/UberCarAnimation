//
//  MapView.swift
//  UberCarSwiftUI
//
//  Created by Surya on 12/02/23.
//

import SwiftUI
import GoogleMaps

struct MapView: UIViewRepresentable {
    var centerCoordinate: CLLocationCoordinate2D? = nil
    let carMarker: GMSMarker!
    let mapView: GMSMapView
    private var carAnimator: CarAnimator!
    var lastUpdatedCoordinate: CLLocationCoordinate2D? = nil

    init(centerCoordinate: CLLocationCoordinate2D?) {
        GMSServices.provideAPIKey(ADD_YOUR_GOOGLE_API_KEY)
        self.centerCoordinate = centerCoordinate
        mapView = GMSMapView()
        carMarker = GMSMarker()
    }
    
    func makeUIView(context: Context) -> GMSMapView {
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
        
     func updateUIView(_ mapView: GMSMapView, context: Self.Context) {
        if let centerCoordinate = centerCoordinate {
            if  carMarker == nil {
                // Update the camera position
                let camera = GMSCameraPosition.camera(withTarget: centerCoordinate, zoom: 15)
                mapView.animate(to: camera)
                carMarker.icon = UIImage(named: "car")
                // Update the car marker position
                carMarker.position = centerCoordinate
                carMarker.map = mapView

            } else if let lastUpdatedCoordinate {
//                if !isStopped {
                    self.mapView.animate(toZoom: 16)
                    carAnimator.animate(from: lastUpdatedCoordinate, to: centerCoordinate)
//                }
            }
        }
        //lastUpdatedCoordinate = centerCoordinate
    }

    
    private func mapStyle(_ style: UIUserInterfaceStyle) -> GMSMapStyle? {
        let styleResourceName = "mapStyle\(style.rawValue)"
            guard let styleURL = Bundle.main.url(forResource: styleResourceName, withExtension: "json") else { return nil }
            let mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
            return mapStyle
    }
        
}
