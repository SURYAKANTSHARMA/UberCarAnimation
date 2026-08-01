//
//  CarAnimation.swift
//  UberCarAnimation
//
//  Created by SuryakantSharma on 28/09/19.
//  Copyright © 2019 Mac mini. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import GoogleMaps // Assuming this project uses Google Maps SDK
import UIKit // For CALayer, CGPoint, CGFloat

final class CarAnimator {
    
    private let carMarker: GMSMarker
    private let mapView: GMSMapView
    
    // Constants for animation durations
    private enum AnimationDuration {
        static let rotation: CFTimeInterval = 1.0
        static let movement: CFTimeInterval = 1.0
    }

    init(carMarker: GMSMarker, mapView: GMSMapView) {
        self.carMarker = carMarker
        self.mapView = mapView
    }
    
    func animate(from sourceCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) {
        #if DEBUG
        print("Animating car from \(sourceCoordinate) to \(destinationCoordinate)")
        #endif

        // Animate car rotation
        CATransaction.begin()
        CATransaction.setAnimationDuration(AnimationDuration.rotation)
        // No specific completion logic needed for rotation, can remove the block if empty.
        // CATransaction.setCompletionBlock { /* ... */ }
        
        // Assuming sourceCoordinate.bearing(to: destinationCoordinate) exists as an extension
        carMarker.rotation = sourceCoordinate.bearing(to: destinationCoordinate)
        carMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5) // Center anchor
        CATransaction.commit()
        
        // Animate car movement
        CATransaction.begin()
        CATransaction.setAnimationDuration(AnimationDuration.movement)
        carMarker.position = destinationCoordinate
        
        // Center map view on the destination
        let cameraUpdate = GMSCameraUpdate.setTarget(destinationCoordinate)
        mapView.animate(with: cameraUpdate)
        
        CATransaction.commit()
    }
    
    /// Pauses the animation of the specified layer.
    /// - Parameter layer: The `CALayer` whose animation needs to be paused.
    func pauseLayer(_ layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    /// Resumes the animation of the specified layer.
    /// - Parameter layer: The `CALayer` whose animation needs to be resumed.
    func resumeLayer(_ layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0 // Reset beginTime
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause // Adjust beginTime to account for the pause duration
    }
}

// Note: This class assumes that an extension exists for
// `CLLocationCoordinate2D` that provides the `bearing(to:)` method.
// For example:
/*
 extension CLLocationCoordinate2D {
     func bearing(to destination: CLLocationCoordinate2D) -> Double {
         let lat1 = self.latitude.toRadians()
         let lon1 = self.longitude.toRadians()
         let lat2 = destination.latitude.toRadians()
         let lon2 = destination.longitude.toRadians()
         
         let deltaLon = lon2 - lon1
         let y = sin(deltaLon) * cos(lat2)
         let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
         let radiansBearing = atan2(y, x)
         
         var degreesBearing = radiansBearing.toDegrees()
         if degreesBearing < 0 {
             degreesBearing += 360.0
         }
         return degreesBearing
     }
 }
 
 extension Double {
     func toRadians() -> Double { self * .pi / 180.0 }
     func toDegrees() -> Double { self * 180.0 / .pi }
 }
 */

