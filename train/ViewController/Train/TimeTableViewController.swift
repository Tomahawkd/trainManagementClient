//
//  TimeTableViewController.swift
//  train
//
//  Created by Ghost on 2018/9/21.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class TimeTableViewController: UIViewController, UITableViewDataSource {
    
    var trainInfo: [TrainInfo] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TripleInfoCell.self, forCellReuseIdentifier: "Train Trip Info Cell")
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Train Trip Info Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TripleInfoCell
        
        if cell == nil {
            cell = TripleInfoCell(style: .default, reuseIdentifier: cellIdentifier)
            cell!.selectionStyle = .none
        }
        
        cell?.setData(trainInfo[indexPath.row].station,
                      trainInfo[indexPath.row].arrivalTime ?? "------",
                      trainInfo[indexPath.row].departTime ?? "------")
        
        return cell!
    }
}
