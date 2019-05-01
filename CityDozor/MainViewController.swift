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
    
    private var model: BusModel?
    private var dataSource = [BusModel]()

    private var coordinates = [BusStopMapItem]()
    
    let semaphore = DispatchSemaphore(value: 1)

    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        return activityIndicatorView
    }()

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        return mapView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.addTarget(self, action: #selector(addRoute), for: .touchUpInside)
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor.blue
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDate()
        setupUI()
    }
    
    private func loadDate() {
        activityIndicatorView.startAnimating()
        Manager.shared.loadMainRequest { [weak self] (dataSource) in
            self?.activityIndicatorView.stopAnimating()
            self?.dataSource = dataSource
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
            make.bottom.equalToSuperview().offset(-30)
            make.height.equalTo(60)
            make.height.equalTo(60)
        }
    }
    
    //MARK: - Actions
    @objc func addRoute() {
        let vc = BusRoutesListViewController(with: dataSource)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    private func cleanOverlays() {
        mapView.removeOverlays(mapView.overlays)
    }
    
    private func setup(with model: BusModel) {
        self.model = model
        
        coordinates = []
        
        
        
        var array1 = model.stops.map( { CLLocationCoordinate2D(latitude: $0.sourceCoordinates.latitude, longitude: $0.sourceCoordinates.longitude)} )
        let myPolyline = MKPolyline(coordinates: array1, count: 10)
        
        mapView.addOverlay(myPolyline)

        
        /*
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
        
        DispatchQueue.global(qos: .background).async {
            
            for (index, model) in self.coordinates.enumerated() {
                
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
//                            let rect = route.polyline.boundingMapRect
//                            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                        }
                    }
                })
            }
        }
 
 */
    }
}

//MARK:- MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue.withAlphaComponent(0.4)
        renderer.lineWidth = 2.0
        return renderer
    }
}

struct BusStopMapItem {
    
    var sourceMapItem: MKMapItem
    var destinationMapItem: MKMapItem
    
    init(with sourceCoordinates: Coordinates, destinationCoordinates: Coordinates) {
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

//MARK:- MKMapViewDelegate
extension MainViewController: BusRoutesListViewControllerDelegate {
    func didSelect(route: BusModel) {
        setup(with: route)
    }
}

