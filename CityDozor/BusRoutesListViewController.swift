//
//  BusRoutesListViewControllerDelegate.swift
//  CityDozor
//
//  Created by A K on 11/17/18.
//  Copyright © 2018 A K. All rights reserved.
//

import UIKit

protocol BusRoutesListViewControllerDelegate: class {
    func didSelect(route: BusModel)
}

class BusRoutesListViewController: UITableViewController {
    
    weak var delegate: BusRoutesListViewControllerDelegate?
    
    private let dataSource: [BusModel]
    
    init(with data: [BusModel]) {
        self.dataSource = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell1")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].name.first ?? ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        delegate?.didSelect(route: model)
        dismiss(animated: true, completion: nil)
    }
}
