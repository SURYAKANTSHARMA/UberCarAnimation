//
//  MapContentViewModel.swift
//  UberCarSwiftUI
//
//  Created by Surya on 12/02/23.
//

import Combine
import CoreLocation

class MapContentViewModel: ObservableObject {
    let locationPublisher = LocationPublisher()
    private var cancellable = Set<AnyCancellable>()
    @Published var lastTwoLocations: (CLLocationCoordinate2D?, CLLocationCoordinate2D?) = (nil, nil)

    deinit {
        print("deinit")
    }

     init() {
        locationPublisher.locationPublisher
            .receive(on: DispatchQueue.main)
            .scan((nil, nil), { locations, location in
                return (locations.1, CLLocationCoordinate2D(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude))
            })
            .compactMap { $0 }
            .sink { [weak self] locations in
                self?.lastTwoLocations = locations
            }.store(in: &cancellable)
    }

}

