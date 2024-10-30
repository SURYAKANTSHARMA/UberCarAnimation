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
            Map(initialPosition: .userLocation(fallback: .automatic)) {
                Annotation("car", coordinate: viewModel.currentCoordinate) {
                    Image(.car)
                        .rotationEffect(.degrees(viewModel.angleInDegrees()))
                }
            }.edgesIgnoringSafeArea(.all)
             .frame(maxWidth: .infinity, maxHeight: .infinity)
             .onAppear {
                    viewModel.setupLocationTracking()
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
}
