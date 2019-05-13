//
//  RouteViewModel.swift
//  CityDozor
//
//  Created by A K on 5/5/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit

class TransportSectionViewModel: NSObject {
    
    enum TransportType: String {
        case bus = "{1}"
        case trolleybus = "{2}"
        
        var title: String {
            switch self {
            case .bus: return "Bus"
            case .trolleybus: return "Trolleybus"
            }
        }
    }
    
    let type: TransportType
    let routes: [Route]
    
    init(with type: TransportType, routes: [Route]) {
        self.type = type
        self.routes = routes
        super.init()
    }
}

class RouteViewModel: NSObject {
    
    var sections = [TransportSectionViewModel]()
    
    init(with routes: [Route]) {
        super.init()
        
        var array = [TransportSectionViewModel]()
        
        let busRoutes = routes.filter({$0.type == TransportSectionViewModel.TransportType.bus.rawValue})
        let trolleybusRoutes = routes.filter({$0.type == TransportSectionViewModel.TransportType.trolleybus.rawValue})

        if !busRoutes.isEmpty {
            let busSection = TransportSectionViewModel(with: .bus, routes: busRoutes)
            array.append(busSection)
        }
        
        if !trolleybusRoutes.isEmpty {
            let trolleybusSection = TransportSectionViewModel(with: .trolleybus, routes: trolleybusRoutes)
            array.append(trolleybusSection)
        }

        sections = array
    }
}
