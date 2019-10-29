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


class ViewController: UIViewController {
    
    // MARK :- Variables
    private var myLocationMarker: GMSMarker!
    @IBOutlet weak var mapView: GMSMapView!
    private var carAnimator: CarAnimator!
    private var stopped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
		configureMapStyle()
        mapView.drawPath(GMSMapView.pathString)
        addButtons()
        LocationTracker.shared.locateMeOnLocationChange { [weak self]  _  in
            self?.moveCarMarker()
        }
    }

    func moveCarMarker() {
        if let myLocation = LocationTracker.shared.lastLocation,
            myLocationMarker == nil {
            myLocationMarker = GMSMarker(position: myLocation.coordinate)
            myLocationMarker.icon = UIImage(named: "car")
            myLocationMarker.map = self.mapView
            carAnimator = CarAnimator(carMarker: myLocationMarker, mapView: mapView)
            self.mapView.updateMap(toLocation: myLocation, zoomLevel: 16)
        } else if let myLocation = LocationTracker.shared.lastLocation?.coordinate, let myLastLocation = LocationTracker.shared.previousLocation?.coordinate {
            if !stopped {
                carAnimator.animate(from: myLastLocation, to: myLocation)
            }
        }
    }

	// MARK: UI Configuration

	private func configureMapStyle() {
		mapView.mapStyle = mapStyle(traitCollection.userInterfaceStyle)
	}
    
    private func addButtons() {
        let playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(playButton)
        playButton.addTarget(self, action: #selector(resumeMarker), for: .touchUpInside)
        
        let pauseButton = UIButton()
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(pauseButton)
        pauseButton.addTarget(self, action: #selector(pauseMarker), for: .touchUpInside)
        
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .black, scale: .large)
            playButton.setImage(UIImage(systemName: "play.circle.fill",withConfiguration: config), for: .normal)
            pauseButton.setImage(UIImage(systemName: "pause.circle.fill",withConfiguration: config), for: .normal)
            playButton.tintColor = .routeColor
            pauseButton.tintColor = .routeColor
        } else {
            playButton.setImage(UIImage(named: "playIcon"), for: .normal)
            pauseButton.setImage(UIImage(named: "pauseIcon"), for: .normal)
        }
        
        NSLayoutConstraint.activate([
            playButton.heightAnchor.constraint(equalToConstant: 60),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            pauseButton.heightAnchor.constraint(equalToConstant: 60),
            pauseButton.widthAnchor.constraint(equalToConstant: 60),
            
            playButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            pauseButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            
            playButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor, constant: -40),
            pauseButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor, constant: 40),
        ])
    }

	// MARK: Helpers

	private func mapStyle(_ style: UIUserInterfaceStyle) -> GMSMapStyle? {
		let styleResourceName = "mapStyle\(style.rawValue)"
		guard let styleURL = Bundle.main.url(forResource: styleResourceName, withExtension: "json") else { return nil }
		let mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
		return mapStyle
	}
    
    //MARK: Selectors
    
    @objc func resumeMarker() {
        guard let markerLayer = carAnimator?.carMarker.layer else { return }
        stopped = false
        carAnimator.resumeLayer(layer: markerLayer)
    }
    
    @objc func pauseMarker() {
        guard let markerLayer = carAnimator?.carMarker.layer else { return }
        stopped = true
        carAnimator.pauseLayer(layer: markerLayer)
    }
}
