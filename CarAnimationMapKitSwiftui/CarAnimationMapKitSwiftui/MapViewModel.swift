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
    var previousCoordinate: CLLocationCoordinate2D?
    unowned var mapView: MKMapView? // Add reference to MKMapView
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func setMapView(_ mapView: MKMapView) {
        self.mapView = mapView
        carAnimator = CarAnimator(mapView: mapView)
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
        
        animateCar()
    }
    
    func animateCar() {
        guard let mapView = self.mapView,
              let previousCoordinate = self.previousCoordinate else { return }
        
        // Find the car annotation on the map
        if let carAnnotationView = mapView.annotations
            .compactMap({ mapView.view(for: $0) as? CarAnnotationView }).first {
            // Animate car movement from the previous to the current location
            carAnnotationView.animateCarMovement(from: previousCoordinate, to: currentCoordinate)
        }
    }
    
    func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        //        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink { [self] _ in
        //            self.carAnimator?.animate(to: currentCoordinate)
        //        }
    }
    
    func stopAnimation() {
        isAnimating = false
        timer?.cancel()
        timer = nil
    }
}
