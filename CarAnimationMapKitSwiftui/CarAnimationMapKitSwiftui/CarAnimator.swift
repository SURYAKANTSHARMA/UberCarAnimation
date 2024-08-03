//
//  CarAnimator.swift
//  CarAnimationMapKitSwiftui
//
//  Created by Suryakant Sharma on 03/08/24.
//

import SwiftUI
import CoreLocation

class CarAnimator {
    @Binding var currentCoordinate: CLLocationCoordinate2D
    
    init(currentCoordinate: Binding<CLLocationCoordinate2D>) {
        _currentCoordinate = currentCoordinate
    }
    
    func updatePosition() {
        // Your animation logic here, e.g., moving the car along a predefined path
    }
}
