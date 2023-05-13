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

    deinit {
        print("deinit")
    }
    override init() {
        super.init()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationPublisher.send(location)
        }
    }
        
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.activityType = . automotiveNavigation
            locationManager.distanceFilter = 10.0  // Movement threshold for new events

            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            manager.startUpdatingLocation()
        } else {
            // User has denied location permission or location services are disabled
        }

    }
}
