//
//  ContentView.swift
//  UberCarSwiftUI
//
//  Created by Surya on 11/02/23.
//

import SwiftUI
import GoogleMaps

struct MapContentView: View {
    
    @State var isPlaying: Bool = false
    @Binding var locations: (CLLocationCoordinate2D?, CLLocationCoordinate2D?)
    @EnvironmentObject var viewModel: MapContentViewModel

    init(locations: Binding<(CLLocationCoordinate2D?, CLLocationCoordinate2D?)>) {
        _locations = locations
        GMSServices.provideAPIKey(ADD_YOUR_GOOGLE_API_KEY)
    }

    var body: some View {
        VStack {
            MapView(currentLocationCoordinate: $locations)
            HStack {
                if isPlaying == false {
                    Button(action: {
                        isPlaying = true
                        viewModel.startPublishing()
                    }) {
                        Image(systemName: "play.fill")
                            .font(.title)
                    }
                } else {
                    Button(action: {
                        // Pause action
                        isPlaying = false
                        viewModel.stopPublishing()
                    }) {
                        Image(systemName: "pause.fill")
                            .font(.title)
                    }
                    
                }
            }
        }.padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    @ObservedObject static var viewModel = MapContentViewModel()

    static var previews: some View {
        MapContentView(locations: $viewModel.lastTwoLocations)
    }
}
