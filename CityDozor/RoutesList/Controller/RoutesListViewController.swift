//
//  BusRoutesListViewControllerDelegate.swift
//  CityDozor
//
//  Created by A K on 11/17/18.
//  Copyright © 2018 A K. All rights reserved.
//

import UIKit

protocol RoutesListViewControllerDelegate: class {
    func didSelectRoute(_ route: Route)
}

class RoutesListViewController: UIViewController {
    
    weak var delegate: RoutesListViewControllerDelegate?
    
    private var selectedRoutes = [Route]()
    private var selectedColors = [Appearance.RouteColor]()
    private let model: RouteModel

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(RouteItemCollectionViewCell.self, forCellWithReuseIdentifier: "RouteItemCollectionViewCell")
        
        return collectionView
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 6
        flowLayout.minimumInteritemSpacing = 6
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: view.frame.size.width / 5, height: 20)
        return flowLayout
    }()
    
    private lazy var closeButton: UIButton = {
        let addRouteButton = UIButton(type: .contactAdd)
        addRouteButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        addRouteButton.tintColor = UIColor.white
        addRouteButton.backgroundColor = UIColor.blue
        return addRouteButton
    }()
    
    
    init(with model: RouteModel) {
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
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(80)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    //MARK: - Actions
    @objc private func closeAction() {
        dismiss(animated: true, completion: nil)
    }
    
    func getRandomRouteColor() -> Appearance.RouteColor {
        let index = Int(arc4random_uniform(5))
        return Appearance.RouteColor(rawValue: index)!
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension RoutesListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.routes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let route = model.routes[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteItemCollectionViewCell", for: indexPath) as! RouteItemCollectionViewCell
        cell.setup(with: route)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let route = model.routes[indexPath.row]
        
        if route.color == .unselected {
            let routeColor = getRandomRouteColor()
            
            if selectedRoutes.count < 5 {
                route.color = routeColor
                selectedRoutes.append(route)
            }
//            else {
//                selectedRoutes.first?.color = .unselected
//                selectedRoutes.remove(at: 0)
//                selectedRoutes.append(route)
//            }
        } else {
            route.color = .unselected
            selectedRoutes.removeAll { $0.id == route.id }
        }
        
        delegate?.didSelectRoute(route)
        collectionView.reloadData()
    }
}

