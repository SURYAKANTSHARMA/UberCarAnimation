//
//  Extensions.swift
//  UberCarAnimation
//
//  Created by tokopedia on 28/09/19.
//  Copyright © 2019 Mac mini. All rights reserved.
//

import GoogleMaps

extension GMSMapView {
    
    static let kPadding: CGFloat = 115
    /*
     Static path String for demoing purpose you will get actual path by direction  api for google for more https://console.cloud.google.com/apis/library/directions-backend.googleapis.com?filter=category:maps&id=c6b51d83-d721-458f-a259-fae6b0af35c5&project=ios-task
     */
    static let pathString: String = "_gfzDaiksMnGeF\\WaCmDyAyBRQJPxHlLdD~EjRrYzJvOzBlDd@K|F}DLGTAX?tHkFJIJX~HdRbKvVBHzBqAnAw@|GcEpDaClApCrBoAhHqEtAw@fC`Gx@`B|@xB^v@B@FAjA}@tNfMdGnFVPNBRG~AwAd@MfK}AJCH^RnAHZN?|Ag@"
    
    func updateMap(toLocation location: CLLocation, zoomLevel: Float? = nil) {
        if let zoomLevel = zoomLevel {
            let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate, zoom: zoomLevel)
            animate(with: cameraUpdate)
        } else {
            animate(toLocation: location.coordinate)
        }
    }
    func drawPath(_ encodedPathString: String) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        let path = GMSPath(fromEncodedPath: encodedPathString)
        let line = GMSPolyline(path: path)
        line.strokeWidth = 4.0
        line.strokeColor = UIColor.black
        line.isTappable = true
        line.map = self
        CATransaction.commit()
    }
}

extension CLLocationCoordinate2D {
    
    func bearing(to point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
        
        let fromLatitude = degreesToRadians(latitude)
        let fromLongitude = degreesToRadians(longitude)
        
        let toLatitude = degreesToRadians(point.latitude)
        let toLongitude = degreesToRadians(point.longitude)
        
        let differenceLongitude = toLongitude - fromLongitude
        
        let y = sin(differenceLongitude) * cos(toLatitude)
        let x = cos(fromLatitude) * sin(toLatitude) - sin(fromLatitude) * cos(toLatitude) * cos(differenceLongitude)
        let radiansBearing = atan2(y, x);
        let degree = radiansToDegrees(radiansBearing)
        return (degree >= 0) ? degree : (360 + degree)
    }
}
