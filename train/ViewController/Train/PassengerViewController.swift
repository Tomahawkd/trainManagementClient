//
//  PassengerViewController.swift
//  train
//
//  Created by Ghost on 2018/9/21.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class PassengerViewController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(TripleInfoCell.self, forCellReuseIdentifier: "Passenger Adder View Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPassenger(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "Add Passenger Segue", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OrderInfoData.shared.passenger.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Passenger Adder View Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TripleInfoCell
        
        if cell == nil {
            cell = TripleInfoCell(style: .default, reuseIdentifier: cellIdentifier)
            cell!.selectionStyle = .none
        }
        
        cell?.setData(OrderInfoData.shared.passenger[indexPath.row].name,
                      OrderInfoData.shared.passenger[indexPath.row].passengerId,
                      OrderInfoData.shared.passenger[indexPath.row].ticket)
        
        return cell!
    }
}
