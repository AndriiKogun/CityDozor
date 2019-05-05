//
//  RouteModel.swift
//  CityDozor
//
//  Created by A K on 5/6/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit
import MapKit

class RouteModel: NSObject {

    var routes = [Route]()
    var busStopsCoordinates = [CLLocationCoordinate2D]()

    func loadRoutes(with completion: @escaping () -> ()) {
        Manager.shared.loadRoutes { [weak self] (routes) in
            if let self = `self` {
                DispatchQueue.global(qos: .userInitiated).async {
                    let busStopsCoordinates = routes.flatMap( { $0.stops.flatMap( { CLLocationCoordinate2D(latitude: $0.sourceCoordinates.latitude, longitude: $0.sourceCoordinates.longitude)} ) })
                    
                    self.busStopsCoordinates = Array(Set(busStopsCoordinates))
                    self.routes = routes
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
}
