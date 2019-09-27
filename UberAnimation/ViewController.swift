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


class ViewController: UIViewController {
    
    // MARK :- Variable
    var myLocationMarker: GMSMarker!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.drawPath(GMSMapView.pathString, adjustToFit: true)
        LocationTracker.shared.locateMeOnLocationChange { [weak self]  _  in
            self?.moveCar()
        }
        
        
    }

    
    func moveCar() {
        if let myLocation = LocationTracker.shared.lastLocation,
            myLocationMarker == nil {
            myLocationMarker = GMSMarker(position: myLocation.coordinate)
            myLocationMarker.icon = UIImage(named: "car")
            myLocationMarker.map = self.mapView
            self.mapView.updateMap(toLocation: myLocation, zoomLevel: 16)
        } else if let myLocation = LocationTracker.shared.lastLocation, let myLastLocation = LocationTracker.shared.previousLocation {
           let degrees = myLastLocation.coordinate.bearing(to: myLocation.coordinate)
           updateMarker(marker: myLocationMarker, coordinates: myLocation.coordinate, degrees: degrees, duration: 0.3)
        }
    }
    
    func updateMarker(marker: GMSMarker, coordinates: CLLocationCoordinate2D, degrees: CLLocationDegrees, duration: Double) {
        // Keep Rotation Short
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
        marker.rotation = degrees
        marker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        CATransaction.commit()
        
        // Movement
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
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
        let degree = radiansToDegrees(radiansBearing)
        return (degree >= 0) ? degree : (360 + degree)
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

extension GMSMapView {
    static let kPadding: CGFloat = 115
    /*
      Static path String for demoing purpose
     */
    static let pathString: String = "ADD YOUR GOOGLE API KEY HERE"
    func drawPath(_ encodedPathString: String, adjustToFit: Bool) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        let path = GMSPath(fromEncodedPath: encodedPathString)
        
//        //adjust map to view all markers
//        if adjustToFit {
//            let bounds = GMSCoordinateBounds(path: path ?? GMSPath())
//            animate(with: GMSCameraUpdate.fit(bounds, withPadding: GMSMapView.kPadding))
//        }
        let line = GMSPolyline(path: path)
        line.strokeWidth = 4.0
        line.strokeColor = UIColor.black
        line.isTappable = true
        line.map = self
        CATransaction.commit()
    }
    
}

