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

    private var transportImageView = UIImageView()
    
    func setAngle(_ angle: Double) {
        let radians = CGFloat(angle * .pi / 180)
        transportImageView.transform = CGAffineTransform(rotationAngle: radians)
    }

    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? TransportAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: -5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            displayPriority = .required
            
            
            transportImageView.image = UIImage(named: "transport")
            
            addSubview(transportImageView)
            transportImageView.snp.makeConstraints { (make) in
                make.width.equalTo(40)
                make.height.equalTo(40)
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
            setAngle(annotation.transport.azi)
        }
    }
}
