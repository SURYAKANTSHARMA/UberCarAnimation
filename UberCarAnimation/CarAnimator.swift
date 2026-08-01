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
import GoogleMaps
import UIKit

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
        // Animate car rotation
        CATransaction.begin()
        CATransaction.setAnimationDuration(AnimationDuration.rotation)
        CATransaction.setCompletionBlock {
            // Optional: Add completion logic here if needed in the future
        }
        carMarker.rotation = sourceCoordinate.bearing(to: destinationCoordinate)
        carMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
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
    
    // Unused CALayer animation helper functions.
    // These can be removed if not utilized elsewhere in the project.
    // If they are intended for future use, they should be made private
    // and potentially moved to a more appropriate utility class.
    // Restoring these methods as they are used by ViewController.
    // Consider making them public if CarAnimator is used by other classes,
    // or keep them internal if only ViewController uses them directly.
    
    public func pauseLayer(_ layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    public func resumeLayer(_ layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
}

