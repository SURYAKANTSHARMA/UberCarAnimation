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

typealias LocationUpdateCallback = (_ location: CLLocation?) -> Void

/**
 LocationTracker to track the user's location and manage location services authorization.
 */
final class LocationTracker: NSObject {
    
    static let shared = LocationTracker()
    
    private(set) var lastLocation: CLLocation?
    private(set) var locations: [CLLocation] = []
    private(set) var previousLocation: CLLocation?
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.activityType = .automotiveNavigation
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = 10 // Only update if distance moved is > 10 meters
        manager.delegate = self
        return manager
    }()
    
    private var locationUpdateCallback: LocationUpdateCallback?
    
    var isCurrentLocationAvailable: Bool {
        guard let lastLoc = lastLocation else { return false }
        // Location is considered current if it's from the last 60 seconds and has some accuracy.
        return abs(lastLoc.timestamp.timeIntervalSinceNow) < 60 && lastLoc.horizontalAccuracy > 0
    }
    
    private override init() {
        super.init()
    }
    
    func requestLocationAccess() {
        locationManager.delegate = self // Ensure delegate is set before requesting authorization
        let currentStatus = locationManager.authorizationStatus
        
        if currentStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if currentStatus == .authorizedWhenInUse {
            // If already authorized for WhenInUse, consider requesting Always authorization
            // This depends on the app's specific needs.
             locationManager.requestAlwaysAuthorization()
        } else if currentStatus == .denied || currentStatus == .restricted {
            // Handle cases where permission is denied or restricted, e.g., guide user to settings.
            print("Location access denied or restricted.")
            // Optionally, invoke a callback to inform the UI.
        } else if currentStatus == .authorizedAlways {
            startUpdatingLocation()
        }
    }
    
    private func startUpdatingLocationBasedOnAuth() {
        let status = locationManager.authorizationStatus
        if status == .authorizedAlways {
            enableBackgroundFeatures()
            locationManager.startUpdatingLocation()
        } else if status == .authorizedWhenInUse {
            disableBackgroundFeatures() // Ensure background features are off for WhenInUse
            locationManager.startUpdatingLocation()
        } else {
            print("Location updates cannot start due to authorization status: \(status)")
        }
    }
    
    private func enableBackgroundFeatures() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false // More continuous tracking if needed
    }

    private func disableBackgroundFeatures() {
        locationManager.allowsBackgroundLocationUpdates = false
    }

    func startTracking(callback: @escaping LocationUpdateCallback) {
        self.locationUpdateCallback = callback
        requestLocationAccess() // This will trigger didChangeAuthorization if status changes or start updates if already authorized.
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationUpdateCallback = nil // Clear callback when tracking stops
        print("Location tracking stopped.")
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationTracker: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations updatedLocations: [CLLocation]) {
        guard let newLocation = updatedLocations.last else { return }
        
        // Validate location: recent (e.g., within last 15 seconds) and valid accuracy
        let locationAge = abs(newLocation.timestamp.timeIntervalSinceNow)
        guard locationAge < 15 && newLocation.horizontalAccuracy > 0 else {
            #if DEBUG
            print("Skipping invalid or old location: \(newLocation)")
            #endif
            return
        }
        
        self.previousLocation = self.lastLocation
        self.lastLocation = newLocation
        self.locations.append(newLocation)
        
        #if DEBUG
        print("Location updated: (\(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude))")
        #endif
        locationUpdateCallback?(newLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        // Optionally, inform the user or retry.
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location authorization status changed to: \(manager.authorizationStatus.rawValue)")
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocationBasedOnAuth()
        case .denied, .restricted:
            // Handle denial or restriction, e.g., update UI, show alert.
            print("Location access was denied or restricted.")
            // Potentially call stopTracking() or a specific handler.
            stopTracking() // Stop updates if authorization is revoked.
        case .notDetermined:
            // This case should ideally be handled by the initial requestLocationAccess call.
            print("Location authorization is not determined.")
        @unknown default:
            print("Unknown location authorization status.")
            // Handle future cases.
        }
    }
}

