//
//  RouteItemCollectionViewCell.swift
//  CityDozor
//
//  Created by A K on 5/5/19.
//  Copyright © 2019 A K. All rights reserved.
//

import UIKit

class RouteItemCollectionViewCell: UICollectionViewCell {
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
//        nameLabel.textColor = UICo
        return nameLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with route: Route) {
        nameLabel.text = route.number
        nameLabel.backgroundColor = route.color.value
    }
    
    private func setupUI() {
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
