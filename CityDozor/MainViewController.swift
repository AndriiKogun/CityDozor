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

    let semaphore = DispatchSemaphore(value: 1)

    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        return activityIndicatorView
    }()

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
//        mapView.register(ArtworkMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ArtworkView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

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
    
    private func cleanOverlays() {
        mapView.removeOverlays(mapView.overlays)
    }
    
    private func setup(with model: BusModel) {
        self.model = model
        
        title = model.number
        
        mapView.removeOverlays(mapView.overlays)
        
        var allCoordinates = [CLLocationCoordinate2D]()
        
        model.routeCoordinates.forEach { (model) in
            let coordinates = model.coordinatesSection.compactMap( { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
            allCoordinates.append(contentsOf: coordinates)
            let overlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(overlay)
        }
        
        let overlay = MKPolyline(coordinates: allCoordinates, count: allCoordinates.count)
//        mapView.setRegion(MKCoordinateRegion(regionRect), animated: true)
        let insets = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
        mapView.setVisibleMapRect(overlay.boundingMapRect, edgePadding: insets, animated: true)
        
        
//        allCoordinates.forEach { (coordinate) in
//            let artwork = ArtworkView(annotation: <#T##MKAnnotation?#>, reuseIdentifier: "marker")
//            
//            
//            let artwork = Artwork(title: "\(coordinate.latitude) \(coordinate.longitude)",
//                                  coordinate: coordinate)
//            mapView.ad
//            
//            mapView.addAnnotation(artwork)
//        }
    }
}

//MARK:- MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? ArtworkView else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation as! MKAnnotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
    }

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue.withAlphaComponent(0.4)
        renderer.lineWidth = 2.0
        return renderer
    }
}

//MARK:- MKMapViewDelegate
extension MainViewController: BusRoutesListViewControllerDelegate {
    func didSelect(route: BusModel) {
        setup(with: route)
    }
}


class ArtworkView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            image = UIImage(named: "bus-stop")
        }
    }
}

class Artwork: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
}


