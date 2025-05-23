//
//  ContentView.swift
//  CarAnimationMapKitSwiftui
//
//  Created by Suryakant Sharma on 03/08/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    
    @StateObject private var viewModel = MapViewModel()
    @State private var route: MKRoute?
    // Default region to show when the map first appears or when currentCoordinate is (0,0)
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.6751951, longitude: 76.7401675), // Default center
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $mapRegion, interactionModes: .all) {
                // Only show annotation if location services are enabled and coordinate is valid
                if viewModel.isLocationServicesEnabled, 
                   viewModel.currentCoordinate.latitude != 0 || viewModel.currentCoordinate.longitude != 0 {
                    Annotation("", coordinate: viewModel.currentCoordinate) {
                        Image(.car) // Assumes "car" image is in Assets
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44) // Give it a reasonable size
                            .rotationEffect(.degrees(viewModel.heading))
                    }
                }
                
                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .mapStyle(.standard)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                viewModel.startLocationUpdates()
                getDirections()
            }
            .onChange(of: viewModel.currentCoordinate) { newCoordinate in
                // Update map region when currentCoordinate changes, only if it's a valid coordinate
                if newCoordinate.latitude != 0 || newCoordinate.longitude != 0 {
                    withAnimation {
                        mapRegion.center = newCoordinate
                        // Optionally adjust span, or keep it user-controlled after initial set
                        mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02) // Zoom in a bit
                    }
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    playButton
                    pauseButton
                 .padding()
                }
            }
        }
    }
    
    
}

#Preview {
    ContentView()
}

extension ContentView {
    var playButton: some View {
        Button(action: {
            viewModel.startLocationUpdates()
        }) {
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
        }
        .padding()
    }
    
    var pauseButton: some View {
        Button(action: {
            viewModel.stopLocationUpdates()
        }) {
            Image(systemName: "pause.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.red)
        }
    }
    
    
    func getDirections() {
        route = nil
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 30.6751951, longitude: 76.7401675)))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 30.6444945, longitude: 76.7247927)))
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            withAnimation {
                route = response?.routes.first
            }
        }
    }

}
