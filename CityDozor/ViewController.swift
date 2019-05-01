//
//  ViewController.swift
//  CityDozor
//
//  Created by A K on 11/17/18.
//  Copyright © 2018 A K. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private var dataSource = [BusModel]()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        return activityIndicatorView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadDate()
    }
    
    private func loadDate() {
        if dataSource.isEmpty {
            activityIndicatorView.startAnimating()
            Manager.shared.loadMainRequest { [weak self] (dataSource) in
                self?.dataSource = dataSource
                self?.activityIndicatorView.startAnimating()
                self?.tableView.reloadData()
            }
        }
    }
    
    private func configureUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell1")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
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
        let vc = MainViewController(with: model)
        navigationController?.pushViewController(vc, animated: true)
    }
}
