//
//  ViewController.swift
//  UberAnimation
//
//  Created by Mac mini on 11/19/18.
//  Copyright © 2018 Mac mini. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

final class ViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let defaultMapZoom: Float = 16.0
        static let carIconName: String = "car"
        static let playIconSystemName: String = "play.circle.fill"
        static let pauseIconSystemName: String = "pause.circle.fill"
        static let playIconFallbackName: String = "playIcon"
        static let pauseIconFallbackName: String = "pauseIcon"
        static let mapStyleResourcePrefix: String = "mapStyle"
        static let mapStyleResourceExtension: String = "json"
        static let buttonSize: CGFloat = 60.0
        static let buttonBottomPadding: CGFloat = -20.0
        static let playButtonCenterXOffset: CGFloat = -40.0
        static let pauseButtonCenterXOffset: CGFloat = 40.0
        static let uiAnimationDuration: TimeInterval = 0.7
    }
    
    // MARK: - Properties
    private var carMarker: GMSMarker?
    private lazy var mapView: GMSMapView = {
        let map = GMSMapView(frame: view.bounds)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return map
    }()
    private var carAnimator: CarAnimator?
    
    private var isAnimationPaused = false {
        didSet {
            updatePlayPauseButtonVisibility()
        }
    }
    
    // MARK: - UI Elements
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Initially hidden, shown when animation is paused
        return button
    }()
    
    private let pauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = false // Initially visible, hidden when animation is paused
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupButtons()
        startLocationTracking()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            configureMapStyle()
        }
    }
    
    // MARK: - Setup
    private func setupMapView() {
        view.addSubview(mapView)
        configureMapStyle()
        // Assuming GMSMapView.pathString is an extension method providing path data
        mapView.drawPath(GMSMapView.pathString)
    }
    
    private func configureMapStyle() {
        mapView.mapStyle = loadMapStyle(for: traitCollection.userInterfaceStyle)
    }
    
    private func setupButtons() {
        mapView.addSubview(playButton)
        mapView.addSubview(pauseButton)
        
        playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(didTapPauseButton), for: .touchUpInside)
        
        configureButtonImages()
        setupButtonConstraints()
    }
    
    private func configureButtonImages() {
        if #available(iOS 13.0, *) {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .black, scale: .large)
            playButton.setImage(UIImage(systemName: Constants.playIconSystemName, withConfiguration: symbolConfig), for: .normal)
            pauseButton.setImage(UIImage(systemName: Constants.pauseIconSystemName, withConfiguration: symbolConfig), for: .normal)
            playButton.tintColor = .routeColor // Assuming UIColor.routeColor is an extension
            pauseButton.tintColor = .routeColor
        } else {
            playButton.setImage(UIImage(named: Constants.playIconFallbackName), for: .normal)
            pauseButton.setImage(UIImage(named: Constants.pauseIconFallbackName), for: .normal)
        }
    }
    
    private func setupButtonConstraints() {
        NSLayoutConstraint.activate([
            playButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            playButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            pauseButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            pauseButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            playButton.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: Constants.buttonBottomPadding),
            pauseButton.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: Constants.buttonBottomPadding),
            
            playButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor, constant: Constants.playButtonCenterXOffset),
            pauseButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor, constant: Constants.pauseButtonCenterXOffset),
        ])
    }
    
    private func startLocationTracking() {
        LocationTracker.shared.startTracking { [weak self] location in
            guard let self = self, let newLocation = location else { return }
            self.handleLocationUpdate(newLocation)
        }
    }
    
    // MARK: - Car Animation Logic
    private func handleLocationUpdate(_ newLocation: CLLocation) {
        let coordinate = newLocation.coordinate
        
        if carMarker == nil {
            initializeCarMarker(at: coordinate, on: newLocation)
        } else if let previousCoordinate = LocationTracker.shared.previousLocation?.coordinate {
            if !isAnimationPaused {
                mapView.animate(toZoom: Constants.defaultMapZoom)
                carAnimator?.animate(from: previousCoordinate, to: coordinate)
            }
        }
    }
    
    private func initializeCarMarker(at coordinate: CLLocationCoordinate2D, on location: CLLocation) {
        let marker = GMSMarker(position: coordinate)
        marker.icon = UIImage(named: Constants.carIconName)
        marker.map = mapView
        self.carMarker = marker
        
        carAnimator = CarAnimator(carMarker: marker, mapView: mapView)
        mapView.updateMap(toLocation: location, zoomLevel: Constants.defaultMapZoom)
        // Ensure buttons are visible after marker is initialized
        updatePlayPauseButtonVisibility()
    }
    
    // MARK: - UI Actions
    @objc private func didTapPlayButton() {
        guard let carAnimator = carAnimator, let markerLayer = carMarker?.layer else { return }
        isAnimationPaused = false
        carAnimator.resumeLayer(markerLayer)
    }
    
    @objc private func didTapPauseButton() {
        guard let carAnimator = carAnimator, let markerLayer = carMarker?.layer else { return }
        isAnimationPaused = true
        carAnimator.pauseLayer(markerLayer)
    }
    
    private func updatePlayPauseButtonVisibility() {
        // Hide playButton if animation is active (not paused), show if paused.
        // Hide pauseButton if animation is paused, show if active.
        // This also implies that if carMarker is nil (animation hasn't started),
        // play should be hidden and pause should be shown (as per initial state).
        let isCarReady = carMarker != nil
        
        UIView.animate(withDuration: Constants.uiAnimationDuration) {
            self.playButton.isHidden = !self.isAnimationPaused || !isCarReady
            self.pauseButton.isHidden = self.isAnimationPaused || !isCarReady
        }
    }
    
    // MARK: - Helpers
    private func loadMapStyle(for userInterfaceStyle: UIUserInterfaceStyle) -> GMSMapStyle? {
        // Assuming rawValue for light is 1 and dark is 2.
        // If mapStyle files are named mapStyle0.json and mapStyle1.json, adjust accordingly.
        // For this example, I'll assume mapStyle2.json is for dark mode, mapStyle1.json for light/unspecified.
        let styleSuffix = (userInterfaceStyle == .dark) ? "2" : "1"
        let styleResourceName = "\(Constants.mapStyleResourcePrefix)\(styleSuffix)"
        
        guard let styleURL = Bundle.main.url(forResource: styleResourceName, withExtension: Constants.mapStyleResourceExtension) else {
            #if DEBUG
            print("Failed to find map style: \(styleResourceName).\(Constants.mapStyleResourceExtension)")
            #endif
            // Fallback to default map style if custom style is not found
            if userInterfaceStyle == .dark, let darkStyleURL = Bundle.main.url(forResource: "\(Constants.mapStyleResourcePrefix)2", withExtension: Constants.mapStyleResourceExtension) {
                 return try? GMSMapStyle(contentsOfFileURL: darkStyleURL)
            } else if let lightStyleURL = Bundle.main.url(forResource: "\(Constants.mapStyleResourcePrefix)1", withExtension: Constants.mapStyleResourceExtension) {
                 return try? GMSMapStyle(contentsOfFileURL: lightStyleURL)
            }
            return nil
        }
        
        do {
            return try GMSMapStyle(contentsOfFileURL: styleURL)
        } catch {
            #if DEBUG
            print("Failed to load map style from URL \(styleURL): \(error)")
            #endif
            return nil
        }
    }
}
