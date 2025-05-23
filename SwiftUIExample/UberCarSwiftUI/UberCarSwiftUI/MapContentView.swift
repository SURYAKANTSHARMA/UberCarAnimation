//
//  ContentView.swift
//  UberCarSwiftUI
//
//  Created by Surya on 11/02/23.
//

import SwiftUI
import GoogleMaps

struct MapContentView: View {
    
    @State private var isPlaying: Bool = false // Keep internal state for button toggle
    
    // This binding will connect to MapContentViewModel's published locationPair
    @Binding var locationPair: (previous: CLLocationCoordinate2D?, current: CLLocationCoordinate2D?)
    
    @EnvironmentObject private var viewModel: MapContentViewModel

    // Removed GMSServices.provideAPIKey from here. It should be done once at app launch.
    init(locationPair: Binding<(previous: CLLocationCoordinate2D?, current: CLLocationCoordinate2D?)>) {
        _locationPair = locationPair
    }

    var body: some View {
        VStack {
            // Pass the current coordinate from the locationPair to MapView
            // MapView will need to be adapted if it expects both, or just the current one.
            // Assuming MapView primarily cares about the current location for display.
            MapView(currentLocationCoordinate: $locationPair.current)
                .edgesIgnoringSafeArea(.top) // Allow map to go under status bar etc.

            HStack(spacing: 30) { // Added spacing for better visual separation
                Button(action: {
                    isPlaying = true
                    viewModel.startLocationUpdates()
                }) {
                    Image(systemName: "play.circle.fill") // Using filled versions for consistency
                        .font(.largeTitle) // Slightly larger for better tap target
                        .foregroundColor(isPlaying ? .gray : .blue) // Indicate active/inactive state
                }
                .disabled(isPlaying) // Disable if already playing

                Button(action: {
                    isPlaying = false
                    viewModel.stopLocationUpdates()
                }) {
                    Image(systemName: "pause.circle.fill") // Using filled versions
                        .font(.largeTitle)
                        .foregroundColor(isPlaying ? .red : .gray) // Indicate active/inactive state
                }
                .disabled(!isPlaying) // Disable if not playing
            }
            .padding(.bottom) // Add some padding at the bottom
        }
        // .padding() // Original padding was on VStack, might not be needed if MapView ignores safe area
    }
}

struct MapContentView_Previews: PreviewProvider {
    // For the preview to work, MapContentViewModel needs to be available in the environment.
    // Also, its locationProvider dependency might need a mock for stable previews if LocationPublisher hits live services.
    // For simplicity, we'll assume the default initializer of MapContentViewModel is sufficient for previews here,
    // but in complex apps, a mock LocationPublishing implementation would be better.
    @StateObject static var previewViewModel = MapContentViewModel()

    static var previews: some View {
        // Ensure the preview has a viewModel in the environment
        MapContentView(locationPair: $previewViewModel.locationPair)
            .environmentObject(previewViewModel)
    }
}
