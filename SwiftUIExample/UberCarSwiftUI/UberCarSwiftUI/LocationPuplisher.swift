//
//  LocationPuplisher.swift
//  UberCarSwiftUI
//
//  Created by Surya on 12/02/23.
//

import Combine
import CoreLocation

class LocationPublisher: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let locationPublisher = PassthroughSubject<CLLocation, Never>()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationPublisher.send(location)
        }
    }
}
