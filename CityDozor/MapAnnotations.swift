//
//  MapAnnotations.swift
//  CityDozor
//
//  Created by A K on 5/3/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit
import MapKit

class BusStopAnnotation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    let imageName = "bus_stop"
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}

class BusStopAnnotationView : MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let artwork = newValue as? BusStopAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: -5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            displayPriority = .required
            image = UIImage(named: artwork.imageName)
        }
    }
}
