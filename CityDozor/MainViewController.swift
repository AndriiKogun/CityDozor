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
   
    var array1 = [CLLocationCoordinate2D]()
    
    var isBusy = false
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        return activityIndicatorView
    }()

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = .satellite
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

    var zoomLevel: Int {
        let maxZoom: Double = 20
        let zoomScale = mapView.visibleMapRect.size.width / Double(mapView.frame.size.width)
        let zoomExponent = log2(zoomScale)
        return Int(maxZoom - ceil(zoomExponent))
    }

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
//        self.addBusStops()

        array1 = dataSource.flatMap( { $0.stops.flatMap( { CLLocationCoordinate2D(latitude: $0.sourceCoordinates.latitude, longitude: $0.sourceCoordinates.longitude)} ) })
        
        array1 = Array(Set(array1))
        
    }
    
    private func addBusRoute(for model: BusModel) {
        var allCoordinates = [CLLocationCoordinate2D]()
        
        model.routeCoordinates.forEach { (model) in
            let coordinates = model.coordinatesSection.compactMap( { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
            allCoordinates.append(contentsOf: coordinates)
            let overlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(overlay)
            
//            let overlay = MKPolyline(coordinates: allCoordinates, count: allCoordinates.count)
            let insets = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
            mapView.setVisibleMapRect(overlay.boundingMapRect, edgePadding: insets, animated: true)

        }
        
//        let overlay = MKPolyline(coordinates: allCoordinates, count: allCoordinates.count)
//        let insets = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
//        mapView.setVisibleMapRect(overlay.boundingMapRect, edgePadding: insets, animated: true)
    }
    
    private func addBusStops() {
        
//
//        var array2 = model!.stops.map( { CLLocationCoordinate2D(latitude: $0.sourceCoordinates.latitude, longitude: $0.sourceCoordinates.longitude)} )

        var array = [BusStopAnnotation]()
        
        dataSource.forEach({ (model) in
            model.stops.forEach { (busStop) in
                let busStop1 = BusStopAnnotation(title: busStop.name.first ?? "",
                                                 locationName: "\(busStop.sourceCoordinates.latitude), \(busStop.sourceCoordinates.longitude)",
                    coordinate: CLLocationCoordinate2D(latitude: busStop.sourceCoordinates.latitude, longitude: busStop.sourceCoordinates.longitude))
                array.append(busStop1)
                
                let busStop2 = BusStopAnnotation(title: busStop.name.first ?? "",
                                                 locationName: "\(busStop.destinationCoordinates.latitude), \(busStop.destinationCoordinates.longitude)",
                    coordinate: CLLocationCoordinate2D(latitude: busStop.destinationCoordinates.latitude, longitude: busStop.destinationCoordinates.longitude))
                array.append(busStop2)
            }
        })
        
        mapView.addAnnotations(array)

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
        guard let annotation = annotation as? BusStopAnnotation else { return nil }
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
        view.isHidden = true
        return view
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        if zoomLevel < 15 {
            isBusy = true
            
            mapView.annotations.forEach { (annotation) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.mapView.view(for: annotation)?.isHidden = true
                })
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.mapView.removeAnnotations(mapView.annotations)
            }
            
//            isBusy = false
        }
    }
    
    private func mapAnnotation(for coordinate: CLLocationCoordinate2D) -> MKAnnotation? {
        return mapView.annotations.first(where: { $0.coordinate == coordinate })
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        array1.forEach { (coordinate) in
            if mapView.visibleMapRect.contains(MKMapPoint(coordinate)) {
                if mapAnnotation(for: coordinate) == nil && self.zoomLevel >= 15 {
                    
                    let busStop = dataSource.map( { $0.stops.first(where: { CLLocationCoordinate2D(latitude: $0.sourceCoordinates.latitude, longitude: $0.sourceCoordinates.longitude) == coordinate }) }).first
                    
                    if let busStop = busStop {
                        let annotation = BusStopAnnotation(title: busStop?.name.first ?? "",
                                                           locationName: "\(coordinate.latitude), \(coordinate.longitude)",
                            coordinate: coordinate)
                        self.mapView.addAnnotation(annotation)

                    }
                }
            } else {
                if let annotation = mapAnnotation(for: coordinate) {
                    self.mapView.removeAnnotation(annotation)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        DispatchQueue.main.async {
            
            views.forEach({ (annotationView) in
//                annotationView.isHidden = true

                UIView.animate(withDuration: 5, animations: {
                    annotationView.isHidden = false
                })
            })
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


extension CLLocationCoordinate2D: Hashable {
    public var hashValue: Int {
        return Int(latitude * 1000)
    }
    
    static public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        // Due to the precision here you may wish to use alternate comparisons
        // The following compares to less than 1/100th of a second
        // return abs(rhs.latitude - lhs.latitude) < 0.000001 && abs(rhs.longitude - lhs.longitude) < 0.000001
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
