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
        nameLabel.textAlignment = .center
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

        UIView.animate(withDuration: 0.1) {
            if route.isSelected {
                self.contentView.layer.borderColor = route.color.value.cgColor
                self.contentView.backgroundColor = route.color.value
                self.nameLabel.textColor = UIColor.white
            } else {
                self.contentView.layer.borderColor = UIColor.white.cgColor
                self.contentView.backgroundColor = UIColor.white
                self.nameLabel.textColor = UIColor.black
            }
        }
    }
    
    private func setupUI() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
