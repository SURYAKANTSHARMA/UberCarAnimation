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
    
    let routeCoordinates: [CLLocationCoordinate2D] =
    [CLLocationCoordinate2D(latitude: 30.6751951, longitude: 76.7401675),
     CLLocationCoordinate2D(latitude: 30.6444945, longitude: 76.7247927)]
    
    private var locationManager = CLLocationManager()
    private var timer: AnyCancellable?
    private var carAnimator: CarAnimator?
    private var isAnimating = false
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func setMapView(_ mapView: MKMapView) {
        carAnimator = CarAnimator(mapView: mapView)
    }

    func setupLocationTracking() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentCoordinate = location.coordinate
    }
    
    func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink { [self] _ in
            self.carAnimator?.animate(to: currentCoordinate)
        }
    }
    
    func stopAnimation() {
        isAnimating = false
        timer?.cancel()
        timer = nil
    }
}