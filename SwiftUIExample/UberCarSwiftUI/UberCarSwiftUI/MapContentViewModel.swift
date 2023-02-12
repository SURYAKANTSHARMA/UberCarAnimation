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
    private var cancellable: AnyCancellable?
    @Published var location: CLLocation?

    func startLocationUpdates() {
        cancellable = locationPublisher.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.location = location
            }
    }

}

