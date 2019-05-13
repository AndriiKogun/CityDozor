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
    
    private var previousSelectedIndexPath: IndexPath!
    private var selectedRoutes = [Route]()
    private var selectedColors = [Appearance.RouteColor]()
    
    private let viewModel: RouteViewModel
    
    private var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.8
        return blurEffectView
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear

        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(RouteItemCollectionViewCell.self,
                                forCellWithReuseIdentifier: RouteItemCollectionViewCell.reuseIdentifier())
        collectionView.register(TransportSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TransportSectionHeaderView.reuseIdentifier())
        return collectionView
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 6
        flowLayout.minimumInteritemSpacing = 6
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 24, right: 10)
        flowLayout.itemSize = CGSize(width: (view.frame.size.width - 6 * 7 - 20) / 7, height: 30)
        flowLayout.headerReferenceSize = CGSize(width: view.frame.size.width, height: 40)
        return flowLayout
    }()
    
    private lazy var closeButton: UIButton = {
        let addRouteButton = UIButton(type: .contactAdd)
        addRouteButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        addRouteButton.tintColor = UIColor.white
        addRouteButton.backgroundColor = UIColor.blue
        return addRouteButton
    }()
    
    init(with routes: [Route]) {
        self.viewModel = RouteViewModel(with: routes)
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
        view.addSubview(blurEffectView)
        blurEffectView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
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
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.sections[section].routes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let route = viewModel.sections[indexPath.section].routes[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RouteItemCollectionViewCell.reuseIdentifier(), for: indexPath) as! RouteItemCollectionViewCell
        cell.setup(with: route)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let route = viewModel.sections[indexPath.section].routes[indexPath.row]
        route.isSelected = !route.isSelected
        route.color = getRandomRouteColor()

        /*
        if route.isSelected {
            route.isSelected = false
            selectedRoutes.removeAll { $0.id == route.id }
        } else {
            route.isSelected = true
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

        }
        */
        delegate?.didSelectRoute(route)
        
        if let previousSelectedIndexPath = previousSelectedIndexPath {
            collectionView.reloadItems(at: [previousSelectedIndexPath, indexPath])
        } else {
            collectionView.reloadItems(at: [indexPath])
        }
        
        previousSelectedIndexPath = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = viewModel.sections[indexPath.section]

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TransportSectionHeaderView.reuseIdentifier(), for: indexPath) as! TransportSectionHeaderView
            header.setup(with: section.type)
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

