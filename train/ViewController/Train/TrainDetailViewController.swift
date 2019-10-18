//
//  TrainDetailViewController.swift
//  train
//
//  Created by Ghost on 2018/9/19.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class TrainDetailViewController: UIViewController, UITableViewDataSource {
    
    var trainStationList: [TrainInfo] = [TrainInfo.empty]
    @IBOutlet weak var titleItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Station Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? StationCell
        
        if cell == nil {
            cell = StationCell(style: .default, reuseIdentifier: cellIdentifier)
            cell!.selectionStyle = .none
        }
        
        cell?.addData(station: trainStationList[indexPath.row].station, depart: trainStationList[indexPath.row].departTime ?? "------",
                      arrival: trainStationList[indexPath.row].arrivalTime ?? "------")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainStationList.count
    }
    
}
