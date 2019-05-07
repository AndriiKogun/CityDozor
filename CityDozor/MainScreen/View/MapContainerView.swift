//
//  MainMapContainerView.swift
//  CityDozor
//
//  Created by A K on 5/4/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit
import MapKit

protocol MapContainerViewDelegate: class {
    func addRouteOnMapAction()
}

class MapContainerView: UIView {
    
    weak var delegate: MapContainerViewDelegate?
    
    private let transportIdentifier = "transportIdentifier"
    private let transportStopIdentifier = "transportStopIdentifier"

    private let model: RouteModel
    private var allCoordinates = [CLLocationCoordinate2D]()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        return activityIndicatorView
    }()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.mapType = .satellite
        mapView.delegate = self
        mapView.register(TransportStopAnnotationView.self, forAnnotationViewWithReuseIdentifier: transportStopIdentifier)
        mapView.register(TransportAnnotationView.self, forAnnotationViewWithReuseIdentifier: transportIdentifier)
        return mapView
    }()
    
    lazy var addRouteButton: UIButton = {
        let addRouteButton = UIButton(type: .contactAdd)
        addRouteButton.addTarget(self, action: #selector(addRouteAction), for: .touchUpInside)
        addRouteButton.tintColor = UIColor.white
        addRouteButton.backgroundColor = UIColor.blue
        addRouteButton.isHidden = true
        return addRouteButton
    }()
    
    private lazy var currentLocationButton: UIButton = {
        let currentLocationButton = UIButton(type: .contactAdd)
        currentLocationButton.addTarget(self, action: #selector(showCurrentLocationAction), for: .touchUpInside)
        currentLocationButton.tintColor = UIColor.white
        currentLocationButton.backgroundColor = UIColor.red
        return currentLocationButton
    }()

    var zoomLevel: Int {
        let maxZoom: Double = 20
        let zoomScale = mapView.visibleMapRect.size.width / Double(mapView.frame.size.width)
        let zoomExponent = log2(zoomScale)
        return Int(maxZoom - ceil(zoomExponent))
    }
    
    init(with model: RouteModel) {
        self.model = model
        super.init(frame: CGRect.zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        mapView.addSubview(addRouteButton)
        addRouteButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
        
        mapView.addSubview(currentLocationButton)
        currentLocationButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-72)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
    }
    
    //MARK: - Actions
    @objc private func addRouteAction() {
        delegate?.addRouteOnMapAction()
    }
    
    @objc private func showCurrentLocationAction() {
        guard let coordinate = mapView.userLocation.location?.coordinate else { return }
        mapView.setCenter(coordinate, animated: true)
    }

    private func cleanMap() {
//        mapView.removeAnnotations(mapView.annotations)
//        mapView.removeOverlays(mapView.overlays)
    }

    func setupMap(with route: Route) {
        if route.color == .unselected {
           let rotePolylines = (mapView.overlays as! [RoutePolyline]).filter( { $0.id == route.id } )
           mapView.removeOverlays(rotePolylines)
        } else {
            route.routeCoordinates.forEach { (model) in
                let coordinates = model.coordinatesSection.compactMap( { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
                allCoordinates.append(contentsOf: coordinates)
                let overlay = RoutePolyline(coordinates: coordinates, count: coordinates.count)
                overlay.color = route.color
                overlay.id = route.id
                mapView.addOverlay(overlay)
            }
        }
        
        let overlay = MKPolyline(coordinates: allCoordinates, count: allCoordinates.count)
        let insets = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
        
        let overlayRect = overlay.boundingMapRect.union(MKMapRect(origin: MKMapPoint(mapView.userLocation.coordinate), size: MKMapSize(width: 1, height: 1)))
        mapView.setVisibleMapRect(overlayRect, edgePadding: insets, animated: true)
    }
    
    func showRegionForLocation(_ location: CLLocation, animated: Bool) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) , span: MKCoordinateSpan(latitudeDelta: 0.016, longitudeDelta: 0.016))
        mapView.setRegion(region, animated: animated)
    }
}

//MARK:- MKMapViewDelegate
extension MapContainerView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is TransportStopAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: transportStopIdentifier) as? TransportStopAnnotationView
            return annotationView
        }
        
        if annotation is TransportAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: transportIdentifier) as? TransportAnnotationView
            return annotationView
        }
        return nil
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        if zoomLevel <= 14 {
            mapView.annotations.forEach { (annotation) in
                if annotation is TransportStopAnnotation {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.mapView.view(for: annotation)?.isHidden = true
                    })
                }
            }
            mapView.annotations.forEach({ (annotation) in
                if annotation is TransportStopAnnotation {
                    self.mapView.removeAnnotation(annotation)
                }
            })
        }
    }
    
    func addTransport(_ transport: [Transport]) {
        mapView.annotations.forEach { (annotation) in
            if annotation is TransportAnnotation {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        transport.forEach { (transport) in
            let annotation = TransportAnnotation(title: transport.plateNumber, coordinate: CLLocationCoordinate2D(latitude: transport.coordinates.latitude, longitude: transport.coordinates.longitude))
            self.mapView.addAnnotation(annotation)
        }
    }
    
    private func mapAnnotation(for coordinate: CLLocationCoordinate2D) -> MKAnnotation? {
        return mapView.annotations.first(where: { $0.coordinate == coordinate })
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        model.busStopsCoordinates.forEach { (coordinate) in
            if mapView.visibleMapRect.contains(MKMapPoint(coordinate)) {
                if mapAnnotation(for: coordinate) == nil && self.zoomLevel > 14 {
                    
                    let busStop = model.routes.compactMap( { $0.stops.first(where: { CLLocationCoordinate2D(latitude: $0.sourceCoordinates.latitude, longitude: $0.sourceCoordinates.longitude) == coordinate}) }).first
                    
                    if let busStop = busStop {
                        let annotation = TransportStopAnnotation(title: busStop.name.first ?? "",
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
        views.forEach({ (annotationView) in
            annotationView.isHidden = false
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? RoutePolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = overlay.color.value
            renderer.lineWidth = 1.6
            return renderer
        }
        return MKOverlayRenderer()
    }
}

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Int(latitude * 1000))
    }
    
    static public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        // Due to the precision here you may wish to use alternate comparisons
        // The following compares to less than 1/100th of a second
        // return abs(rhs.latitude - lhs.latitude) < 0.000001 && abs(rhs.longitude - lhs.longitude) < 0.000001
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
