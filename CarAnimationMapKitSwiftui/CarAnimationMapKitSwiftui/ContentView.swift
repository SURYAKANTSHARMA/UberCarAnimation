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

    var body: some View {
        ZStack {
            MapView(coordinate: $viewModel.currentCoordinate,
                    routeCoordinates: viewModel.routeCoordinates)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    viewModel.setupLocationTracking()
                }
            
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        viewModel.startAnimation()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    
                    Button(action: {
                        viewModel.stopAnimation()
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.red)
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
