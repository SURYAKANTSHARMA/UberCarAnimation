//
//  CarAnimation.swift
//  UberCarAnimation
//
//  Created by tokopedia on 28/09/19.
//  Copyright © 2019 Mac mini. All rights reserved.
//

import Foundation
import GoogleMaps

struct CarAnimator {
    let carMarker: GMSMarker
    let mapView: GMSMapView
    
    func animate(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        // Keep Rotation Short
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
        carMarker.rotation = source.bearing(to: destination)
        carMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        CATransaction.commit()
        
        // Movement
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
        carMarker.position = destination
        
        // Center Map View
        let camera = GMSCameraUpdate.setTarget(destination)
        mapView.animate(with: camera)
        
        CATransaction.commit()
    }
}

