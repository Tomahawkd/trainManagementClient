//
//  TrainViewController.swift
//  train
//
//  Created by Ghost on 2018/9/19.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class TrainViewController: UIViewController {
    
    @IBOutlet weak var searchButton:UIButton!
    
    private let adminButton = UIButton(frame: CGRect(x: 37, y: 320, width: 300, height: 30))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButton.layer.cornerRadius = 5.0
        
        let dformat = DateFormatter()
        dformat.dateFormat = "yyyy-MM-dd"
        TripStationData.shared.date = dformat.string(from: Date())
        
        adminButton.setTitle("Manage Train", for: .normal)
        adminButton.setTitleColor(.white, for: .normal)
        adminButton.backgroundColor = UIColor(red: CGFloat(0), green: CGFloat(0.5), blue: CGFloat(1), alpha: CGFloat(1))
        adminButton.addTarget(self, action: #selector(manage(_:)), for: .touchUpInside)
        adminButton.layer.cornerRadius = 5.0
        
        if Account.shared.accountRole == Account.admin {
            self.view.addSubview(adminButton)
        } else {
            adminButton.removeFromSuperview()
        }
    }
    
    @objc func manage(_ sender: UIButton) {
        performSegue(withIdentifier: "Train manage Segue", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Account.shared.accountRole == Account.admin {
            self.view.addSubview(adminButton)
        } else {
            adminButton.removeFromSuperview()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tripViewController = segue.destination as? TripViewController {
            
            Train.shared.whileSuccessful = { str, action in
                self.clearAllNotice()
            }
            Train.shared.whileErrorOccurs = { str in
                self.clearAllNotice()
                self.noticeError(str)
            }
            
            self.noticeInfo("Loading", autoClear: false)
            Train.shared.getTrip(start: TripStationData.shared.depart,
                                 end: TripStationData.shared.arrival) { result in
                tripViewController.tripList = result ?? [Trip.empty]
                tripViewController.tableView.reloadData()
            }
        } else if let trainDetailViewController = segue.destination as? TrainDetailViewController,
            let train = sender as? String {
            
            Train.shared.whileSuccessful = { str, action in
                self.clearAllNotice()
            }
            Train.shared.whileErrorOccurs = { str in
                self.clearAllNotice()
                self.noticeError(str)
            }
            
            self.noticeInfo("Loading", autoClear: false)
            Train.shared.getTrainInfo(id: train) { result in
                trainDetailViewController.titleItem.title = train
                trainDetailViewController.trainStationList = result
                trainDetailViewController.tableView.reloadData()
            }
        }
    }
    @IBAction func searchTrain(_ sender: UIButton) {
        var inputText = UITextField()
        let msgAlertCtr = UIAlertController.init(title: "Search", message: "Please input train number", preferredStyle: .alert)
        
        msgAlertCtr.addAction(UIAlertAction.init(title: "Confirm", style:.default) { (action) -> () in
            if let input = inputText.text {
                if input.substring(to: 1) == "g" && Int(input.substring(from: 1) ?? "N") != nil {
                    self.performSegue(withIdentifier: "Train Detail Segue", sender: input)
                } else {
                    self.noticeError("Invalid train number")
                }
            }
        })
        msgAlertCtr.addAction(UIAlertAction.init(title: "Cancel", style:.cancel) { (action) -> () in })
        msgAlertCtr.addTextField { (textField) in
            inputText = textField
            inputText.placeholder = "information"
        }
        self.present(msgAlertCtr, animated: true, completion: nil)
    }
}

class TripStationData {
    
    static let shared = TripStationData()
    
    var depart = ""
    var arrival = ""
    
    var date = ""
}
