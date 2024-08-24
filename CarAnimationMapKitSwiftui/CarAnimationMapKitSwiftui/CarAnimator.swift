//
//  CarAnimator.swift
//  CarAnimationMapKitSwiftui
//
//  Created by Suryakant Sharma on 03/08/24.
//

import SwiftUI
import CoreLocation
import MapKit

class CarAnimator {
    unowned let mapView: MKMapView
    
    init(mapView: MKMapView) {
        self.mapView = mapView
    }
    
    func animate(to destination: CLLocationCoordinate2D) {
        guard let carAnnotation = mapView.annotations.first(where: { $0 is CarAnnotation }) as? CarAnnotation,
              let carAnnotationView = mapView.view(for: carAnnotation) else {
            return
        }
        
        let source = carAnnotation.coordinate
        
        // Keep Rotation Short
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
        CATransaction.setCompletionBlock({
            // you can do something here
        })
        carAnnotationView.transform = CGAffineTransform(rotationAngle: CGFloat(source.bearing(to: destination)))
        carAnnotationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        CATransaction.commit()
        
        // Movement
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
        carAnnotation.coordinate = destination
        
        // Center Map View
        let region = MKCoordinateRegion(center: destination, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        CATransaction.commit()
    }
    
    func pauseLayer(layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    func resumeLayer(layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
}

class CarAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

extension CLLocationCoordinate2D {
    func bearing(to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = self.latitude.toRadians()
        let lon1 = self.longitude.toRadians()
        let lat2 = destination.latitude.toRadians()
        let lon2 = destination.longitude.toRadians()
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x)
        
        return bearing.toDegrees()
    }
}

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
