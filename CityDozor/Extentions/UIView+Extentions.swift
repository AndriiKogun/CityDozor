//
//  UIView+Extentions.swift
//  CityDozor
//
//  Created by A K on 5/13/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit

extension UIView {
    
    class func reuseIdentifier() -> String {
        return String(describing: self)
    }

}
