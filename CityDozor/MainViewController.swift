//
//  MainViewController.swift
//  CityDozor
//
//  Created by A K on 5/1/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit
import MapKit
import SnapKit

class MainViewController: UIViewController {
    
    private let model: BusModel
    private var routes = [MKRoute]()
    
    private var coordinates = [BusStopMapItem]()


    private lazy var button: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(action), for: .touchUpInside)
        button.setTitle("Start", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        return button
    }()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        return mapView
    }()

    init(with model: BusModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc func action() {
        
        
        var array1 = model.stops.map( { $0.sourceCoordinates } )

        var array2 = model.stops.map( { $0.destinationCoordinates } )
        let first = array1.first!
        array1.append(first)
        array1.remove(at: 0)

        
        for (index, model) in model.stops.enumerated() {
            let source1 = array1[index]
            let source2 = array2[index]

            let item = BusStopMapItem(with: source1, destinationCoordinates: source2)
            coordinates.append(item)
        }
        
        DispatchQueue.global(qos: .utility).async {

            self.coordinates.forEach({ (model) in

                let directionsRequest = MKDirections.Request()
                directionsRequest.transportType = .walking
                directionsRequest.source = model.sourceMapItem
                directionsRequest.destination = model.destinationMapItem
                directionsRequest.requestsAlternateRoutes = false
                
                let direction = MKDirections(request: directionsRequest)
                
                direction.calculate(completionHandler: { [weak self] (response, error) in
                    if let self = `self` {
                        if error != nil {
                            print("There was an error getting your directions")
                            return
                        }
                        
                        guard let route = response?.routes.first else {
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.mapView.addOverlay(route.polyline)
                            
                            let rect = route.polyline.boundingMapRect
                            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                        }
                    }
                })
            })
        }
    }
    
    
    private func setupUI() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        mapView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.height.equalTo(80)
        }
        
    }
}

//MARK:- MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
}

struct BusStopMapItem {
    
    var sourceMapItem: MKMapItem
    var destinationMapItem: MKMapItem
    
    init(with sourceCoordinates: BusStopCoordinates, destinationCoordinates: BusStopCoordinates) {
        let originLocationCoordinate2D = CLLocationCoordinate2D(latitude: sourceCoordinates.latitude,
                                                                longitude: sourceCoordinates.longitude)
        let destinationLocationCoordinate2D = CLLocationCoordinate2D(latitude: destinationCoordinates.latitude,
                                                                     longitude: destinationCoordinates.longitude)

        let originPlacemark = MKPlacemark(coordinate: originLocationCoordinate2D)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocationCoordinate2D)

        sourceMapItem = MKMapItem(placemark: originPlacemark)
        destinationMapItem = MKMapItem(placemark: destinationPlacemark)
    }
}
