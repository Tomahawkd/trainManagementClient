//
//  TrainMenuViewController.swift
//  train
//
//  Created by Ghost on 2018/9/19.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class TrainMenuViewController: UITableViewController {
    
    @IBOutlet weak var departStation: UIButton!
    @IBOutlet weak var arrivalStation: UIButton!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 10.0
        searchButton.layer.cornerRadius = 5.0
        
        departStation.titleLabel?.adjustsFontSizeToFitWidth = true
        arrivalStation.titleLabel?.adjustsFontSizeToFitWidth = true
        
        TripStationData.shared.depart = departStation.titleLabel?.text ?? ""
        TripStationData.shared.arrival = arrivalStation.titleLabel?.text ?? ""
        
        date.text = TripStationData.shared.date
    }
    
    @IBAction func departEdit(_ sender: UIButton) {
        generateInputView(label: "depart", oldValue: TripStationData.shared.depart)
    }
    
    @IBAction func arrivalEdit(_ sender: UIButton) {
        generateInputView(label: "arrival", oldValue: TripStationData.shared.arrival)
    }
    
    
    @IBAction func switchStation(_ sender: UIButton) {
        let t = TripStationData.shared.depart
        TripStationData.shared.depart = TripStationData.shared.arrival
        TripStationData.shared.arrival = t
        self.departStation.setTitle(TripStationData.shared.depart, for: .normal)
        self.arrivalStation.setTitle(TripStationData.shared.arrival, for: .normal)

    }
    
    @IBAction func searchTrip(_ sender: UIButton) {
        self.parent!.performSegue(withIdentifier: "Trip Info Segue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            self.parent!.performSegue(withIdentifier: "Calendar Segue", sender: self)
        }
    }
    
    fileprivate func generateInputView(label: String, oldValue: String) {
        var inputText = UITextField()
        let msgAlertCtr = UIAlertController.init(title: "Edit value", message: "Please input \(label) station", preferredStyle: .alert)
        
        msgAlertCtr.addAction(UIAlertAction.init(title: "Confirm", style:.default) { (action) -> () in
            if let input = inputText.text {
                if label == "depart" {
                    TripStationData.shared.depart = input
                    self.departStation.setTitle(TripStationData.shared.depart, for: .normal)
                } else if label == "arrival" {
                    TripStationData.shared.arrival = input
                    self.arrivalStation.setTitle(TripStationData.shared.arrival, for: .normal)
                }
            }
        })
        msgAlertCtr.addAction(UIAlertAction.init(title: "Cancel", style:.cancel) { (action) -> () in })
        msgAlertCtr.addTextField { (textField) in
            inputText = textField
            inputText.text = oldValue
            inputText.placeholder = "information"
        }
        self.present(msgAlertCtr, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        date.text = TripStationData.shared.date
    }
}
