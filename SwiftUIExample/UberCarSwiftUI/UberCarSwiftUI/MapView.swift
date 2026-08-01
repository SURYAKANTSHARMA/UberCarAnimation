//
//  MapView.swift
//  UberCarSwiftUI
//
//  Created by Surya on 12/02/23.
//

import SwiftUI
import GoogleMaps
import CoreLocation // Ensure CoreLocation is imported for CLLocationCoordinate2D

struct MapView: UIViewRepresentable {
    // Binding to the current coordinate, assuming this is the 'current' part of the locationPair
    @Binding var currentLocationCoordinate: CLLocationCoordinate2D? 
    // Binding to the previous coordinate, which is the 'previous' part of locationPair
    @Binding var previousLocationCoordinate: CLLocationCoordinate2D?

    // Coordinator class to manage GMSMapView interactions and CarAnimator
    class Coordinator: NSObject {
        var parent: MapView
        var carMarker: GMSMarker?
        var carAnimator: CarAnimator?
        var initialMarkerSetupDone: Bool = false

        init(_ parent: MapView) {
            self.parent = parent
            super.init()
        }

        func updateCarPosition(on mapView: GMSMapView) {
            guard let currentCoord = parent.currentLocationCoordinate else {
                // If current coordinate is nil, maybe hide marker or do nothing
                carMarker?.map = nil // Hide marker if current location is unknown
                return
            }

            if carMarker == nil {
                let marker = GMSMarker(position: currentCoord)
                marker.icon = UIImage(named: "car") // Ensure "car" image is in assets
                self.carMarker = marker
            }
            
            guard let carMarker = self.carMarker else { return }

            if carAnimator == nil {
                self.carAnimator = CarAnimator(carMarker: carMarker, mapView: mapView)
            }

            // Ensure marker is on the map
            if carMarker.map == nil {
                carMarker.map = mapView
            }
            
            // Update marker's position directly if there's no previous coordinate for animation
            // or if it's the very first setup.
            guard let prevCoord = parent.previousLocationCoordinate, initialMarkerSetupDone else {
                if !initialMarkerSetupDone { // First time, just place the marker
                    carMarker.position = currentCoord
                     // Center map on the first valid coordinate
                    let camera = GMSCameraPosition.camera(withTarget: currentCoord, zoom: 15.0)
                    mapView.camera = camera // Use non-animated set for initial position
                    initialMarkerSetupDone = true
                } else { // Current is valid, previous is not - marker already on map, just update.
                     // This case implies a jump, so animate smoothly if possible or just set.
                     // For simplicity, just setting position if previous is nil but current is not.
                     // A more sophisticated approach might involve a short animation.
                    if carMarker.position.latitude != currentCoord.latitude || carMarker.position.longitude != currentCoord.longitude {
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(0.5) // Short animation for position update
                        carMarker.position = currentCoord
                        CATransaction.commit()
                    }
                }
                return
            }
            
            // Animate from previous to current
            if carMarker.position.latitude != currentCoord.latitude || carMarker.position.longitude != currentCoord.longitude {
                 carAnimator?.animate(from: prevCoord, to: currentCoord)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        let initialCameraLatitude = currentLocationCoordinate?.latitude ?? 30.6751951 // Default if nil
        let initialCameraLongitude = currentLocationCoordinate?.longitude ?? 76.7401675 // Default if nil
        
        let camera = GMSCameraPosition.camera(
            withLatitude: initialCameraLatitude,
            longitude: initialCameraLongitude,
            zoom: 14.0) // Initial zoom
        
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.settings.myLocationButton = true // Example: enable my location button
        mapView.isMyLocationEnabled = true    // Example: show user's blue dot

        // Apply map style
        mapView.mapStyle = mapStyle(UITraitCollection.current.userInterfaceStyle)

        // Draw a demo path (optional, could be removed or made dynamic)
        // If GMSMapView.pathString is not defined, this will cause an error.
        // Assuming it's an extension similar to the other project.
        // mapView.drawPath(GMSMapView.pathString) 

        // Initial car marker setup will be handled in updateUIView via coordinator
        // to ensure it happens when coordinates are first available.
        return mapView
    }
        
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        context.coordinator.updateCarPosition(on: mapView)
        
        // Update map style if interface style changes (e.g. dark/light mode)
        // This check might be better handled by observing traitCollection changes directly if needed.
        // For simplicity, applying it here ensures it's re-evaluated.
        let currentMapStyle = mapStyle(UITraitCollection.current.userInterfaceStyle)
        if mapView.mapStyle?.description != currentMapStyle?.description { // Avoid redundant style applications
            mapView.mapStyle = currentMapStyle
        }
    }
    
    private func mapStyle(_ style: UIUserInterfaceStyle) -> GMSMapStyle? {
        // Assuming mapStyle1 for light, mapStyle2 for dark.
        let styleResourceName = (style == .dark) ? "mapStyle2" : "mapStyle1"
        guard let styleURL = Bundle.main.url(forResource: styleResourceName, withExtension: "json") else {
            #if DEBUG
            print("MapView: Failed to find map style JSON: \(styleResourceName).json")
            #endif
            return nil
        }
        do {
            return try GMSMapStyle(contentsOfFileURL: styleURL)
        } catch {
            #if DEBUG
            print("MapView: Failed to load map style from \(styleURL): \(error)")
            #endif
            return nil
        }
    }
}

// GMSMapView.pathString extension would be needed if drawPath is used.
// Example:
/*
extension GMSMapView {
    static var pathString: String {
        // Return your encoded polyline string here
        return "your_encoded_polyline_string"
    }
    func drawPath(_ encodedPathString: String) {
        guard !encodedPathString.isEmpty, let path = GMSPath(fromEncodedPath: encodedPathString) else { return }
        let line = GMSPolyline(path: path)
        line.strokeWidth = 4.0
        // Ensure UIColor.routeColor is defined (e.g., in Assets or via extension)
        // line.strokeColor = UIColor.routeColor 
        line.strokeColor = .blue // Fallback
        line.map = self
    }
}
*/
