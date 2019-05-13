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
    
    dynamic var coordinate: CLLocationCoordinate2D

    let title: String?
    let color: UIColor
    let transport: Transport
        
    init(transport: Transport, color: UIColor) {
        self.title = transport.plateNumber
        self.color = color
        self.transport = transport
        self.coordinate = CLLocationCoordinate2D(latitude: transport.coordinates.latitude, longitude: transport.coordinates.longitude)
        super.init()
    }
}
