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
import FloatingPanel

class MainViewController: UIViewController {
    
    private let model = RouteModel()
    
    var fpc: FloatingPanelController!
    var searchVC: RoutesListViewController!

    private lazy var locationManager: LocationManager = {
        let locationManager = LocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    private lazy var mapContainerView: MapContainerView = {
        let mapContainerView = MapContainerView(with: model)
        mapContainerView.delegate = self
        return mapContainerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDate()
        setupUI()
        locationManager.showCurrentLocation()
        
    }
    
    func createPanel() {
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        searchVC = RoutesListViewController(with: model)
        searchVC.delegate = self
        
        // Initialize FloatingPanelController and add the view
        fpc.surfaceView.backgroundColor = UIColor.clear
        fpc.surfaceView.cornerRadius = 6
        fpc.surfaceView.shadowHidden = true
        fpc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
        fpc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
        
        // Set a content view controller
        fpc.set(contentViewController: searchVC)
        fpc.track(scrollView: searchVC.collectionView)
        
        fpc.addPanel(toParent: self)
        fpc.hide(animated: false, completion: nil)
    }

    private func loadDate() {
        model.getRoutes { [weak self] in
            if let self = `self` {
                self.createPanel()
                self.mapContainerView.addRouteButton.isHidden = false
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(mapContainerView)
        mapContainerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

//MARK:- MKMapViewDelegate
extension MainViewController: RoutesListViewControllerDelegate {
    func didSelectRoute(_ route: Route) {
        title = route.number
        mapContainerView.setupMap(with: route)
        
        model.getTransport(routeId: route.id) {
            self.mapContainerView.addTransport(self.model.transport)
        }
    }
}

//MARK: - LocationManagerDelegate
extension MainViewController: LocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFindLocation location: CLLocation) {
        mapContainerView.showRegionForLocation(location, animated: false)
    }
}

//MARK: - MainMapContainerViewDelegate
extension MainViewController: MapContainerViewDelegate {
    func addRouteOnMapAction() {
        fpc.show(animated: true, completion: nil)
        
        
        
        
    }
}

//MARK: - FloatingPanelControllerDelegate
extension MainViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return FloatingPanelStocksLayout()
    }
    
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        if vc.position == .full {
            // Dimiss top bar with dissolve animation
        }
    }
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        if targetPosition == .full {
            // Present top bar with dissolve animation
        }
    }
}

class FloatingPanelStocksLayout: FloatingPanelLayout {
    var initialPosition: FloatingPanelPosition {
        return .full
    }
    
    var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .tip]
    }
    
    var topInteractionBuffer: CGFloat { return 0.0 }
    var bottomInteractionBuffer: CGFloat { return 0.0 }
    
    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 200
        case .half: return 262.0
        case .tip: return 0// Visible + ToolView
        default: return nil
        }
    }
    
    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}

