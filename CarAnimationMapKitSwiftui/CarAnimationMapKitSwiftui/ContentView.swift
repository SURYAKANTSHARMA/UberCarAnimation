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
    
    var body: some View {
        ZStack {
            Map(initialPosition: .userLocation(fallback: .automatic)) {
                Annotation("", coordinate: viewModel.currentCoordinate) {
                    Image(.car)
                        .rotationEffect(.degrees(viewModel.angleInDegrees()))
                }
                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }.mapStyle(.standard)
             .edgesIgnoringSafeArea(.all)
             .frame(maxWidth: .infinity, maxHeight: .infinity)
             .onAppear {
                    viewModel.setupLocationTracking()
                    getDirections()
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
            viewModel.startAnimation()
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
            viewModel.stopAnimation()
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
