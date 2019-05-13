//
//  TransportStopAnnotationView.swift
//  CityDozor
//
//  Created by A K on 5/3/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit
import MapKit

class TransportStopAnnotationView : MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? TransportStopAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: -5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            displayPriority = .required
            image = UIImage(named: annotation.imageName)
        }
    }
}
