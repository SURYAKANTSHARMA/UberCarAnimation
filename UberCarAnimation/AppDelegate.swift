//
//  AppDelegate.swift
//  UberAnimation
//
//  Created by Mac mini on 11/19/18.
//  Copyright © 2018 Mac mini. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /// For more info visit https://developers.google.com/maps/documentation/ios-sdk/get-api-key#get_key
        GMSServices.provideAPIKey(ADD_YOUR_GOOGLE_API_KEY)
        return true
    }
}

