//
//  StationCell.swift
//  train
//
//  Created by Ghost on 2018/9/20.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class StationCell: UITableViewCell {
    
    @IBOutlet weak var station: UILabel!
    @IBOutlet weak var depart: UILabel!
    @IBOutlet weak var arrival: UILabel!
    
    func addData(station: String, depart: String, arrival: String) {
        self.station.text = station
        self.depart.text = depart
        self.arrival.text = arrival
    }
}
