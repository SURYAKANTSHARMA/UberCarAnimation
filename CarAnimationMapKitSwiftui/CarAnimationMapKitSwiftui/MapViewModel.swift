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

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var currentCoordinate = CLLocationCoordinate2D()
    private var locationManager = CLLocationManager()
    var previousCoordinate: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
        
    func angleInDegrees() -> Double {
        guard let previousCoordinate = previousCoordinate else { return 0 }
        return previousCoordinate.bearing(to: currentCoordinate)
    }
    
    func setupLocationTracking() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        previousCoordinate = currentCoordinate
        currentCoordinate = location.coordinate
    }
    
    
    func startAnimation() {
        setupLocationTracking()
    }
    
    func stopAnimation() {
        locationManager.stopUpdatingLocation()
    }
}

extension CLLocationCoordinate2D {
    func bearing(to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = self.latitude.toRadians()
        let lon1 = self.longitude.toRadians()
        let lat2 = destination.latitude.toRadians()
        let lon2 = destination.longitude.toRadians()
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x)
        
        return bearing.toDegrees()
    }
}

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
