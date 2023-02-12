//
//  ContentView.swift
//  UberCarSwiftUI
//
//  Created by Surya on 11/02/23.
//

import SwiftUI
import GoogleMaps

struct ContentView: View {
    var body: some View {
        VStack {
            MapView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
