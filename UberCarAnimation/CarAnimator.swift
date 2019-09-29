//
//  CarAnimation.swift
//  UberCarAnimation
//
//  Created by tokopedia on 28/09/19.
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

