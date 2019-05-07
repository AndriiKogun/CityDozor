//
//  TransportAnnotationView.swift
//  CityDozor
//
//  Created by A K on 5/8/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit
import MapKit

class TransportAnnotationView: MKAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? TransportAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: -5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            displayPriority = .required
            image = UIImage(named: annotation.imageName)
        }
    }
}
