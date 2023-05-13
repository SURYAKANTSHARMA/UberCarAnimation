//
//  UberCarSwiftUIApp.swift
//  UberCarSwiftUI
//
//  Created by Surya on 11/02/23.
//

import SwiftUI
import GoogleMaps
let ADD_YOUR_GOOGLE_API_KEY = "AIzaSyCd66Czq6Ezt72pOAKe27rTgM_PCVZDl0U"

@main
struct UberCarSwiftUIApp: App {
    @StateObject var viewModel = MapContentViewModel()

    var body: some Scene {
        WindowGroup {
            MapContentView(locations: $viewModel.lastTwoLocations)
                .environmentObject(viewModel)
        }
    }
}
