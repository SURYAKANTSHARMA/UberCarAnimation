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
    @ObservedObject var viewModel = MapContentViewModel()
    
    var body: some View {
        VStack {
            MapView(centerCoordinate: viewModel.location?.coordinate)
            HStack {
                if isPlaying == false {
                    Button(action: {
                        isPlaying = true
                    }) {
                        Image(systemName: "play.fill")
                            .font(.title)
                    }
                } else {
                    Button(action: {
                        // Pause action
                        isPlaying = false
                    }) {
                        Image(systemName: "pause.fill")
                            .font(.title)
                    }

                }
              }
            }.padding()
            .onAppear() {
               
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapContentView()
    }
}
