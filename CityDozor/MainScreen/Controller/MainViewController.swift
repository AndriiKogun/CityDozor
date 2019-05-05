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
        
        
        // Do any additional setup after loading the view, typically from a nib.
        // Initialize FloatingPanelController
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        // Initialize FloatingPanelController and add the view
        fpc.surfaceView.backgroundColor = .clear
        fpc.surfaceView.cornerRadius = 9.0
        fpc.surfaceView.shadowHidden = false
        
        searchVC = RoutesListViewController(with: model)
        searchVC.delegate = self

        // Set a content view controller
        fpc.set(contentViewController: searchVC)
        fpc.track(scrollView: searchVC.collectionView)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //  Add FloatingPanel to a view with animation.
//        fpc.addPanel(toParent: self, animated: true)
    }

    private func loadDate() {
        model.loadRoutes { [weak self] in
            if let self = `self` {
                
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
//        let vc = RoutesListViewController(with: model)
//        vc.delegate = self
//        present(vc, animated: true, completion: nil)
        
        fpc.addPanel(toParent: self, animated: true)
    }
}

//MARK: - FloatingPanelControllerDelegate
extension MainViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        switch newCollection.verticalSizeClass {
        case .compact:
            fpc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
            fpc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
            return SearchPanelLandscapeLayout()
        default:
            fpc.surfaceView.borderWidth = 0.0
            fpc.surfaceView.borderColor = nil
            return nil
        }
    }
    
    func floatingPanelDidMove(_ vc: FloatingPanelController) {
        let y = vc.surfaceView.frame.origin.y
        let tipY = vc.originYOfSurface(for: .tip)
        if y > tipY - 44.0 {
            let progress = max(0.0, min((tipY  - y) / 44.0, 1.0))
            self.searchVC.collectionView.alpha = progress
        }
    }
    
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        if vc.position == .full {
//            searchVC.searchBar.showsCancelButton = false
//            searchVC.searchBar.resignFirstResponder()
        }
    }
    
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        if targetPosition != .full {
//            searchVC.hideHeader()
        }
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        if targetPosition == .tip {
                            self.searchVC.collectionView.alpha = 0.0
                        } else {
                            self.searchVC.collectionView.alpha = 1.0
                        }
        }, completion: nil)
    }
}

public class SearchPanelLandscapeLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .tip]
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0
        case .tip: return 69.0
        default: return nil
        }
    }
    
    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        if #available(iOS 11.0, *) {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
                surfaceView.widthAnchor.constraint(equalToConstant: 291),
            ]
        } else {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0),
                surfaceView.widthAnchor.constraint(equalToConstant: 291),
            ]
        }
    }
    
    public func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}



