//
//  UberCarSwiftUIApp.swift
//  UberCarSwiftUI
//
//  Created by Surya on 11/02/23.
//

import SwiftUI
import GoogleMaps // Ensure GoogleMaps is imported

@main
struct UberCarSwiftUIApp: App {
    // Instantiate the ViewModel that will be shared
    @StateObject private var mapContentViewModel = MapContentViewModel()

    init() {
        // Provide the Google Maps API key at app launch.
        // 'googleMapsAPIKey' should be defined in a separate 'keys.swift' file (which should be in .gitignore).
        // Example: let googleMapsAPIKey = "YOUR_ACTUAL_API_KEY"
        GMSServices.provideAPIKey(googleMapsAPIKey)
        print("Google Maps API Key Provided.")
    }

    var body: some Scene {
        WindowGroup {
            // Pass the binding to the refactored property name in MapContentViewModel
            MapContentView(locationPair: $mapContentViewModel.locationPair)
                .environmentObject(mapContentViewModel)
        }
    }
}

