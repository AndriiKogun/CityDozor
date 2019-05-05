//
//  Appearance.swift
//  CityDozor
//
//  Created by A K on 5/4/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit

class Appearance: NSObject {
    
    enum RouteColor: Int {
        case red
        case blue
        case yellow
        case green
        case purple
        case unselected
        
        var value: UIColor {
            switch self {
            case .red: return UIColor.red
            case .blue: return UIColor.blue
            case .yellow: return UIColor.yellow
            case .green: return UIColor.green
            case .purple: return UIColor.purple
            case .unselected: return UIColor.white
            }
        }
    }
    
    static var shared: Appearance {
        setup()
        return Appearance()
    }
    
    private static func setup() {
    }
    
}
