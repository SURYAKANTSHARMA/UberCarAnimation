//
//  MapViewModel.swift
//  CarAnimationMapKitSwiftui
//
//  Created by Suryakant Sharma on 03/08/24.
//
import Foundation
import CoreLocation
import Combine
import MapKit

final class MapViewModel: NSObject, ObservableObject {
    
    @Published var currentCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0) // Initialize with a default
    @Published var heading: Double = 0.0 // Represents the bearing/heading of the car
    @Published var isLocationServicesEnabled: Bool = false // Reflects overall location services status

    private let locationManager: CLLocationManager
    private var previousCoordinate: CLLocationCoordinate2D?

    // Configuration constants
    private enum Config {
        static let defaultDistanceFilter: CLLocationDistance = 10 // meters
        static let defaultDesiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBestForNavigation
        static let recentLocationMaxAge: TimeInterval = 15 // seconds
        static let minimumHorizontalAccuracy: CLLocationAccuracy = 20 // meters
    }

    /// Initializes the ViewModel.
    /// - Parameter locationManager: An optional `CLLocationManager` instance.
    ///   If `nil` (default), a new `CLLocationManager` is created.
    ///   This allows injecting a mock manager for testing.
    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        // Configure the locationManager passed in, or the default one.
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        locationManager.desiredAccuracy = Config.defaultDesiredAccuracy
        locationManager.distanceFilter = Config.defaultDistanceFilter
        locationManager.activityType = .automotiveNavigation
    }
        
    /// Calculates the bearing from the previous coordinate to the current coordinate.
    /// Returns 0 if previous coordinate is not available.
    private func calculateBearing() -> Double {
        guard let previous = previousCoordinate else { return 0 }
        // Ensure currentCoordinate is different from previous to avoid NaN issues with atan2 if they were identical
        // and to ensure there's actual movement to calculate a bearing.
        guard currentCoordinate.latitude != previous.latitude || currentCoordinate.longitude != previous.longitude else {
            return self.heading // Maintain last known heading if no movement
        }
        return previous.bearing(to: currentCoordinate)
    }
    
    /// Initiates location tracking after checking authorization.
    func startLocationUpdates() {
        handleAuthorizationStatus(locationManager.authorizationStatus)
    }
    
    /// Stops location tracking.
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        print("Location updates stopped.")
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            isLocationServicesEnabled = false
            // Optionally, trigger an alert or UI change to inform the user
            print("Location access denied or restricted.")
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationServicesEnabled = true
            locationManager.startUpdatingLocation()
            print("Location updates started.")
        @unknown default:
            print("Unknown authorization status.")
            isLocationServicesEnabled = false
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        // Validate location data
        let locationAge = abs(newLocation.timestamp.timeIntervalSinceNow)
        guard locationAge < Config.recentLocationMaxAge,
              newLocation.horizontalAccuracy > 0,
              newLocation.horizontalAccuracy < Config.minimumHorizontalAccuracy else {
            #if DEBUG
            print("Skipping outdated or inaccurate location: \(newLocation)")
            #endif
            return
        }
        
        // Update coordinates and heading
        self.previousCoordinate = self.currentCoordinate // Update previous before current
        self.currentCoordinate = newLocation.coordinate
        self.heading = calculateBearing()
        
        #if DEBUG
        // print("Location updated: \(newLocation.coordinate), Heading: \(self.heading)")
        #endif
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        isLocationServicesEnabled = false // Reflect error in services availability
        // Potentially handle specific errors, e.g., CLCLError.denied
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Authorization status changed to: \(manager.authorizationStatus.rawValue)")
        handleAuthorizationStatus(manager.authorizationStatus)
    }
}

// MARK: - Coordinate & Angle Utilities
// These extensions could be moved to a separate utility file if used more broadly.

fileprivate extension CLLocationCoordinate2D {
    /// Calculates the bearing in degrees from the current coordinate to a destination coordinate.
    func bearing(to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = self.latitude.toRadians()
        let lon1 = self.longitude.toRadians()
        let lat2 = destination.latitude.toRadians()
        let lon2 = destination.longitude.toRadians()
        
        let deltaLon = lon2 - lon1
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let bearingRadians = atan2(y, x)
        
        let bearingDegrees = bearingRadians.toDegrees()
        // Normalize to 0-360 range
        return (bearingDegrees >= 0) ? bearingDegrees : (bearingDegrees + 360.0)
    }
}

fileprivate extension Double {
    /// Converts degrees to radians.
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    /// Converts radians to degrees.
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
