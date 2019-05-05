//
//  RouteViewModel.swift
//  CityDozor
//
//  Created by A K on 5/5/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit

enum TransportKind {
    case bus
    case trolleybus
    
    var name: String {
        switch self {
        case .bus: return "Bus"
        case .trolleybus: return "trolleybus"
        }
    }
}

class TransportKindViewModel: NSObject {
    
    var kind: TransportKind!
    var routes = [RouteViewModel]()
    
    
    init(with route: Route) {
        super.init()
        
        
    }
    

}

class RouteViewModel: NSObject {
    
    var color = Appearance.RouteColor.unselected
    
    
}
