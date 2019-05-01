//
//  DetailTableViewController.swift
//  CityDozor
//
//  Created by A K on 11/18/18.
//  Copyright © 2018 A K. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    private var items: [BusStop]
    
    init(items: [BusStop]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell2")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
        let text = items[indexPath.row].name.first ?? ""
        cell.textLabel?.text = text
        return cell
    }
}
