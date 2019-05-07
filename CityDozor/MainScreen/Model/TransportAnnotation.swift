//
//  TransportAnnotation.swift
//  CityDozor
//
//  Created by A K on 5/8/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit
import MapKit

class TransportAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    let imageName = "Transport"
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
}
