//
//  AppDelegate.swift
//  UberAnimation
//
//  Created by Mac mini on 11/19/18.
//  Copyright © 2018 Mac mini. All rights reserved.
//

import UIKit
import GoogleMaps

@main // Modern replacement for @UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Provide Google Maps API Key
        // Ensure `googleMapsAPIKey` is defined, ideally in a separate, gitignored file (e.g., keys.swift)
        GMSServices.provideAPIKey(googleMapsAPIKey) 
        
        // Setup the main window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

