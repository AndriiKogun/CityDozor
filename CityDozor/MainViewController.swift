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
    private var busStopsisVisible = false
   
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        return activityIndicatorView
    }()

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.register(BusStopAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        return mapView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.addTarget(self, action: #selector(addRoute), for: .touchUpInside)
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor.blue
        button.isHidden = true
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
            if let self = `self` {
                self.button.isHidden = false
                self.activityIndicatorView.stopAnimating()
                self.dataSource = dataSource
            }
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
    
    private func cleanMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    private func setup(with model: BusModel) {
        self.model = model
        
        title = model.number
        
        cleanMap()
        addBusRoute(for: model)
    }
    private func addBusRoute(for model: BusModel) {
        var allCoordinates = [CLLocationCoordinate2D]()
        
        model.routeCoordinates.forEach { (model) in
            let coordinates = model.coordinatesSection.compactMap( { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
            allCoordinates.append(contentsOf: coordinates)
            let overlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(overlay)
        }
        
        let overlay = MKPolyline(coordinates: allCoordinates, count: allCoordinates.count)
        let insets = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
        mapView.setVisibleMapRect(overlay.boundingMapRect, edgePadding: insets, animated: true)
    }
    
    private func addBusStops(for model: BusModel) {
        model.stops.forEach { (busStop) in
            let artwork1 = BusStopAnnotation(title: busStop.name.first ?? "",
                                             locationName: "None",
                                             discipline: "Sculpture",
                                             coordinate: CLLocationCoordinate2D(latitude: busStop.sourceCoordinates.latitude, longitude: busStop.sourceCoordinates.longitude))
            mapView.addAnnotation(artwork1)
            
            let artwork2 = BusStopAnnotation(title: busStop.name.first ?? "",
                                             locationName: "None",
                                             discipline: "Sculpture",
                                             coordinate: CLLocationCoordinate2D(latitude: busStop.sourceCoordinates.latitude, longitude: busStop.sourceCoordinates.longitude))
            mapView.addAnnotation(artwork2)
        }
    }
    
    private func setBusStops(visible: Bool) {
        for case let annotation as BusStopAnnotation in mapView.annotations {
            UIView.animate(withDuration: 0.1) {
                self.mapView.view(for: annotation)?.isHidden = !visible
            }
        }
    }
}

//MARK:- MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? BusStopAnnotation else { return nil }
        // 3
        let identifier = "marker"
        var view: BusStopAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? BusStopAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = BusStopAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        guard let model = model else {
            return
        }
        
        if mapView.region.span.latitudeDelta < 0.025 {
            if mapView.annotations.isEmpty {
                addBusStops(for: model)
            } else if !busStopsisVisible {
                busStopsisVisible = true
                setBusStops(visible: true)
            }
        } else {
            if busStopsisVisible {
                busStopsisVisible = false
                setBusStops(visible: false)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 1.0
        return renderer
    }
}

//MARK:- MKMapViewDelegate
extension MainViewController: BusRoutesListViewControllerDelegate {
    func didSelect(route: BusModel) {
        setup(with: route)
    }
}

class BusStopAnnotation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    let imageName = "bus_stop"

    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}

class BusStopAnnotationView : MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let artwork = newValue as? BusStopAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: -5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            displayPriority = .required
            image = UIImage(named: artwork.imageName)
        }
    }
}

