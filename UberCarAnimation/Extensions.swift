//
//  Extensions.swift
//  UberCarAnimation
//
//  Created by Suryakant Sharma on 28/09/19.
//  Copyright © 2019 Mac mini. All rights reserved.
//

import GoogleMaps
import UIKit // Added for UIColor

// MARK: - GMSMapView Extension
extension GMSMapView {
    
    /**
     A static encoded path string for demonstration purposes.
     For actual applications, obtain path data using the Google Directions API.
     More info: https://developers.google.com/maps/documentation/directions/start
     */
    static let demoEncodedPathString: String = "_gfzDaiksMnGeF\\WaCmDyAyBRQJPxHlLdD~EjRrYzJvOzBlDd@K|F}DLGTAX?tHkFJIJX~HdRbKvVBHzBqAnAw@|GcEpDaClApCrBoAhHqEtAw@fC`Gx@`B|@xB^v@B@FAjA}@tNfMdGnFVPNBRG~AwAd@MfK}AJCH^RnAHZN?|Ag@"
    
    /**
     Updates the map camera to center on a given location, optionally with a specific zoom level.
     - Parameters:
        - location: The `CLLocation` to center the map on.
        - zoomLevel: An optional `Float` value for the zoom level. If nil, the map animates to the location with the current zoom.
     */
    func updateMap(toLocation location: CLLocation, zoomLevel: Float? = nil) {
        if let newZoomLevel = zoomLevel {
            let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate, zoom: newZoomLevel)
            self.animate(with: cameraUpdate)
        } else {
            self.animate(toLocation: location.coordinate)
        }
    }
    
    /**
     Draws a polyline on the map from an encoded path string.
     - Parameter encodedPathString: A `String` representing the encoded path.
     */
    func drawPath(_ encodedPathString: String) {
        // Use a CATransaction to ensure the path is drawn immediately without animation.
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        
        guard let path = GMSPath(fromEncodedPath: encodedPathString) else {
            #if DEBUG
            print("Error: Could not create GMSPath from encoded string.")
            #endif
            CATransaction.commit()
            return
        }
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 4.0
        polyline.strokeColor = UIColor.routeColor // Assumes UIColor.routeColor is defined
        polyline.isTappable = true // Example: make line tappable if needed for interaction
        polyline.map = self
        
        CATransaction.commit()
    }
}

// MARK: - UIColor Extension
extension UIColor {
    /// A custom color for routes, loaded from Asset Catalog. Falls back to black if not found.
    static var routeColor: UIColor {
        // Ensure "routeColor" is defined in your Asset Catalog.
        guard let color = UIColor(named: "routeColor") else {
            #if DEBUG
            print("Warning: 'routeColor' not found in Asset Catalog. Falling back to UIColor.black.")
            #endif
            return .black
        }
        return color
    }
}

// MARK: - CLLocationCoordinate2D Extension
extension CLLocationCoordinate2D {
    
    /**
     Calculates the bearing (direction) from the current coordinate to another coordinate.
     - Parameter destination: The `CLLocationCoordinate2D` of the destination.
     - Returns: A `Double` representing the bearing in degrees (0-360).
     */
    func bearing(to destination: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { degrees * .pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { radians * 180.0 / .pi }
        
        let lat1 = degreesToRadians(latitude)
        let lon1 = degreesToRadians(longitude)
        
        let lat2 = degreesToRadians(destination.latitude)
        let lon2 = degreesToRadians(destination.longitude)
        
        let deltaLon = lon2 - lon1
        
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let radiansBearing = atan2(y, x)
        
        let degreesBearing = radiansToDegrees(radiansBearing)
        return (degreesBearing >= 0) ? degreesBearing : (degreesBearing + 360.0)
    }
}

// MARK: - CLLocationCoordinate2D Equatable Conformance
extension CLLocationCoordinate2D: Equatable {
    /**
     Compares two `CLLocationCoordinate2D` instances for equality based on their latitude and longitude.
     - Parameters:
        - lhs: The left-hand side `CLLocationCoordinate2D`.
        - rhs: The right-hand side `CLLocationCoordinate2D`.
     - Returns: `true` if the coordinates are equal, `false` otherwise.
     */
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    /**
     Calculates the distance in meters from the current coordinate to another coordinate.
     - Parameter otherCoordinate: The `CLLocationCoordinate2D` to calculate the distance to.
     - Returns: A `CLLocationDistance` (Double) representing the distance in meters.
     */
    func distance(to otherCoordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let-      destinationLocation = CLLocation(latitude: otherCoordinate.latitude, longitude: otherCoordinate.longitude)
        let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        return currentLocation.distance(from: destinationLocation)
    }
}
