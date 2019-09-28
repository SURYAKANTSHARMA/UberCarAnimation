//
//  LocationManager.swift
//  UberCarAnimation
//
//  Created by Mac mini on 8/20/18.
//  Copyright © 2018 Mac mini. All rights reserved.
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
import CoreLocation

typealias LocateMeCallback = (_ location: CLLocation?) -> Void

/*
 LocationTracker to track the user in while navigating from one place to other and store new locations in locations array.
 **/
class LocationTracker: NSObject {
    
    static let shared = LocationTracker()
    
    var lastLocation: CLLocation?
    var locations: [CLLocation] = []
    var previousLocation: CLLocation?
    
    var locationManager: CLLocationManager = {
       let locationManager = CLLocationManager()
       locationManager.activityType = .automotiveNavigation
       locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
       locationManager.distanceFilter = 10
       return locationManager
    }()
    
    var locateMeCallback: LocateMeCallback?
   
    var isCurrentLocationAvailable: Bool {
        if lastLocation != nil, lastLocation!.timestamp.timeIntervalSinceNow < 10 {
          return true
        }
        return false
    }
    
    func enableLocationServices() {
        locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Disable location features
            print("Fail permission to get current location of user")
        case .authorizedWhenInUse:
            // Enable basic location features
            enableMyWhenInUseFeatures()
       case .authorizedAlways:
            // Enable any of your app's location features
            enableMyAlwaysFeatures()
        @unknown default:
            break 
        }
    }
    
    func enableMyWhenInUseFeatures() {
       locationManager.startUpdatingLocation()
       locationManager.delegate = self
        
       escalateLocationServiceAuthorization()
    }
    
    func escalateLocationServiceAuthorization() {
        // Escalate only when the authorization is set to when-in-use
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func enableMyAlwaysFeatures() {
       locationManager.allowsBackgroundLocationUpdates = true
       locationManager.pausesLocationUpdatesAutomatically = true
       locationManager.startUpdatingLocation()
       locationManager.delegate = self
    }
    
    func locateMeOnLocationChange(callback: @escaping LocateMeCallback) {
        self.locateMeCallback = callback
        if lastLocation == nil {
            enableLocationServices()
        } else {
           callback(lastLocation)
        }
    }
    
    func startTracking() {
         enableLocationServices()
    }
    
    func stopTracking() {
        
    }
    private override init() {}
}

// MARK: - CLLocationManagerDelegate
extension LocationTracker: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        
        guard let location = locations.first else { return }
        
        guard location.timestamp.timeIntervalSinceNow < 10 || location.horizontalAccuracy > 0 else {
            print("invalid location received")
            return
        }
        
        self.locations.append(location)
        previousLocation = lastLocation
        lastLocation = location
        
        print("location = \(location.coordinate.latitude) \(location.coordinate.longitude)")
        locateMeCallback?(location)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        enableLocationServices()
    }
}

