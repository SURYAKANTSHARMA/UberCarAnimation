//
//  ViewController.swift
//  UberAnimation
//
//  Created by Mac mini on 11/19/18.
//  Copyright © 2018 Mac mini. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation


typealias JSON = [String: Double]
typealias JSONArray = [JSON]

class ViewController: UIViewController {
    
    var myLocationMarker: GMSMarker!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        mapView.isMyLocationEnabled = true

        LocationTracker.shared.locateMe { [weak self]  _  in
            LocationTracker.shared.startTracking()
            self?.moveCar()
        }
        
    }

    
    func moveCar() {
        if let myLocation = LocationTracker.shared.lastLocation, myLocationMarker == nil {
            myLocationMarker = GMSMarker(position: myLocation.coordinate)
            myLocationMarker.icon = UIImage(named: "car")
            myLocationMarker.map = self.mapView
            self.mapView.updateMap(toLocation: myLocation, zoomLevel: 16)
        }
        
        Timer.scheduledTimer(withTimeInterval: 1 , repeats: true) { _  in
            if let myLocation = LocationTracker.shared.lastLocation {
                self.updateMarker(marker: self.myLocationMarker, coordinates: myLocation.coordinate, degrees: LocationTracker.shared.previousLocation?.coordinate.bearing(to: myLocation.coordinate) ?? 0.0, duration: 1.0)
            }
        }
    }
    
    func updateMarker(marker: GMSMarker, coordinates: CLLocationCoordinate2D, degrees: CLLocationDegrees, duration: Double) {
        // Keep Rotation Short
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        marker.rotation = degrees
        CATransaction.commit()
        
        // Movement
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        marker.position = coordinates
        
        // Center Map View
        let camera = GMSCameraUpdate.setTarget(coordinates)
        mapView.animate(with: camera)
        
        CATransaction.commit()
    }

}


extension CLLocationCoordinate2D {
    
    func bearing(to point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
        
        let lat1 = degreesToRadians(latitude)
        let lon1 = degreesToRadians(longitude)
        
        let lat2 = degreesToRadians(point.latitude);
        let lon2 = degreesToRadians(point.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansToDegrees(radiansBearing)
    }
    
}

extension GMSMapView {
    func updateMap(toLocation location: CLLocation, zoomLevel: Float? = nil) {
        if let zoomLevel = zoomLevel {
            let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate, zoom: zoomLevel)
            animate(with: cameraUpdate)
        } else {
            animate(toLocation: location.coordinate)
        }
    }
}
