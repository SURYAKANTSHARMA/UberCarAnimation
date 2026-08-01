//
//  MapContentViewModel.swift
//  UberCarSwiftUI
//
//  Created by Surya on 12/02/23.
//

import Combine
import CoreLocation

// Define a protocol that LocationPublisher can conform to, for better testability and DI.
protocol LocationPublishing: AnyObject {
    var locationPublisher: AnyPublisher<CLLocation, Never> { get }
    func start()
    func stop()
}

final class MapContentViewModel: ObservableObject {
    private let locationProvider: LocationPublishing // Use the protocol type
    private var cancellables = Set<AnyCancellable>()
    
    @Published var locationPair: (previous: CLLocationCoordinate2D?, current: CLLocationCoordinate2D?) = (nil, nil)

    // deinit { print("MapContentViewModel deinit") } // For debugging, remove for production

    init(locationProvider: LocationPublishing = LocationPublisher()) { // Default to LocationPublisher instance
        self.locationProvider = locationProvider
        
        self.locationProvider.locationPublisher
            .receive(on: DispatchQueue.main)
            // Use scan to keep track of the previous and current location.
            .scan((nil, nil)) { (previousPair, newLocation) -> (CLLocationCoordinate2D?, CLLocationCoordinate2D?) in
                let newCoordinate = CLLocationCoordinate2D(
                    latitude: newLocation.coordinate.latitude,
                    longitude: newLocation.coordinate.longitude
                )
                return (previousPair.1, newCoordinate)
            }
            // The scan operation itself provides the tuple. No need for compactMap here unless we want to filter out initial (nil, CLLocationCoordinate2D)
            // For this logic, we always want to publish the pair.
            .sink { [weak self] (prev, curr) in
                self?.locationPair = (previous: prev, current: curr)
            }
            .store(in: &cancellables)
    }
    
    func stopLocationUpdates() {
        locationProvider.stop()
    }
    
    func startLocationUpdates() {
        locationProvider.start()
    }
}

