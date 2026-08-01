//
//  LocationPublisher.swift
//  UberCarSwiftUI
//
//  Created by Surya on 12/02/23.
//

import Combine
import CoreLocation

// Protocol defined in MapContentViewModel.swift
// protocol LocationPublishing: AnyObject {
//     var locationPublisher: AnyPublisher<CLLocation, Never> { get }
//     func start()
//     func stop()
// }

final class LocationPublisher: NSObject, LocationPublishing {
    
    private let locationManager: CLLocationManager
    private let subject = PassthroughSubject<CLLocation, Never>()
    
    var locationPublisher: AnyPublisher<CLLocation, Never> {
        subject.eraseToAnyPublisher()
    }

    // Configuration constants
    private enum Config {
        static let defaultDistanceFilter: CLLocationDistance = 10 // meters
        static let defaultDesiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBestForNavigation
        static let recentLocationMaxAge: TimeInterval = 15 // seconds
        static let minimumHorizontalAccuracy: CLLocationAccuracy = 20 // meters
    }

    // deinit { print("LocationPublisher deinit") } // For debugging

    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self // Set delegate first
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = Config.defaultDistanceFilter
        locationManager.desiredAccuracy = Config.defaultDesiredAccuracy
    }
    
    func start() {
        print("LocationPublisher: Attempting to start location updates.")
        // Handle authorization status before starting
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            print("LocationPublisher: Started updating location.")
        case .restricted, .denied:
            print("LocationPublisher: Location access restricted or denied.")
            // Optionally, send an error or state update through a different publisher if needed
        @unknown default:
            print("LocationPublisher: Unknown authorization status.")
        }
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        print("LocationPublisher: Stopped updating location.")
    }
}

extension LocationPublisher: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        // Validate location data
        let locationAge = abs(newLocation.timestamp.timeIntervalSinceNow)
        guard locationAge < Config.recentLocationMaxAge,
              newLocation.horizontalAccuracy > 0, // Must be positive
              newLocation.horizontalAccuracy < Config.minimumHorizontalAccuracy else { // Must be better than threshold
            #if DEBUG
            // print("LocationPublisher: Skipping outdated or inaccurate location: \(newLocation)")
            #endif
            return
        }
        
        #if DEBUG
        // print("LocationPublisher: Publishing new location: \(newLocation.coordinate)")
        #endif
        subject.send(newLocation)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("LocationPublisher: Authorization status changed to: \(manager.authorizationStatus.rawValue)")
        // If authorization changes, re-evaluate whether to start or stop updates.
        // `start()` method already contains this logic.
        // Avoid calling start() directly if it could lead to re-requesting auth unnecessarily.
        // For now, let's just ensure updates start if we become authorized.
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
             // Check if already updating, to avoid redundant start calls if not necessary,
             // though CLLocationManager handles redundant calls to startUpdatingLocation gracefully.
            locationManager.startUpdatingLocation()
            print("LocationPublisher: Started updating on authorization change.")
        } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            // If permission is revoked, stop updates.
            stop()
            // Optionally, notify the app (e.g. ViewModel) about this state if it needs to react beyond just stopping.
            // For example, by publishing an error or a status.
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationPublisher: Location manager failed with error: \(error.localizedDescription)")
        // Optionally, send this error through the publisher or another mechanism
        // subject.send(completion: .failure(error)) // If publisher could fail
    }
}
