//
//  OrderTripViewController.swift
//  train
//
//  Created by Ghost on 2018/9/21.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class OrderTripViewController: UIViewController, UITableViewDataSource {
    
    var tripInfo: [TrainInfo] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(TripleInfoCell.self, forCellReuseIdentifier: "Order Trip View Cell")
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Order Trip View Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TripleInfoCell
        
        if cell == nil {
            cell = TripleInfoCell(style: .default, reuseIdentifier: cellIdentifier)
            cell!.selectionStyle = .none
        }
        
        cell?.setData(tripInfo[indexPath.row].station,
                      tripInfo[indexPath.row].arrivalTime ?? "------",
                      tripInfo[indexPath.row].departTime ?? "------")
        
        return cell!
    }
    
    
}
