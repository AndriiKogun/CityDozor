//
//  LocationManager.swift
//  CityDozor
//
//  Created by A K on 5/4/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationManagerDelegate: class {
    func locationManager(_ manager: CLLocationManager, didFindLocation location: CLLocation)
}

class LocationManager: NSObject {
    
    weak var delegate: LocationManagerDelegate?
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = 2
        locationManager.delegate = self
        return locationManager
    }()

    private var isInitialLocation = true
    
    func showCurrentLocation() {
        let status = CLLocationManager.authorizationStatus()
        
        if CLLocationManager.locationServicesEnabled() {
            if status == .notDetermined {
                locationManager.requestAlwaysAuthorization()
            } else {
                print("Need Location permission")
            }
            locationManager.startUpdatingLocation()
        } else {
            print("Please turn on location services or GPS")
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if isInitialLocation {
            isInitialLocation = false
            delegate?.locationManager(manager, didFindLocation: locations[0])
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .denied {
            locationManager.startUpdatingLocation()
        }
    }
}
