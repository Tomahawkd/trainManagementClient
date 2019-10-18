//
//  TripInfoViewController.swift
//  train
//
//  Created by Ghost on 2018/9/21.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class TripInfoViewController: UIViewController {
    
    var tripInfo = Trip.empty
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var departLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    
    override func viewDidLoad() {
        OrderInfoData.shared.complete = 1
        OrderInfoData.shared.order = []
        OrderInfoData.shared.passenger = []
        OrderInfoData.shared.date = TripStationData.shared.date
        
        titleLabel.text = tripInfo.title
        departLabel.text = "Depart Time: \(tripInfo.trip[0].departTime ?? "00:00:00")"
        arrivalLabel.text = "Arrival Time: \(tripInfo.trip[tripInfo.trip.count - 1].arrivalTime ?? "00:00:00")"
        
        OrderInfoData.shared.order.append(OrderElement.empty)
        OrderInfoData.shared.order[0].trainId = tripInfo.trip[0].trainId
        
        var index = 0
        var tip = 0
        for t in tripInfo.trip {
            if t.trainId != OrderInfoData.shared.order[0].trainId {
                tip = index
                OrderInfoData.shared.complete = 2
                OrderInfoData.shared.order.append(OrderElement.empty)
                OrderInfoData.shared.order[1].trainId = t.trainId
            }
            index += 1
        }
        
        if OrderInfoData.shared.complete == 1 {
            tip = tripInfo.trip.count
        }
        
        let start = tripInfo.trip[0].stationOrder
        let end = tripInfo.trip[tip - 1].stationOrder
        var station = 0
        
        Train.shared.whileSuccessful = ignoreSuccess
        Train.shared.whileErrorOccurs = error
        
        Train.shared.getTrainInfo(id: tripInfo.trip[0].trainId) { info in
            station = info.count
            let departArrival = Order.shared.generateDepartArrival(stationCount: station, start: start, end: end)
            OrderInfoData.shared.order[0].departArrival = departArrival
            
            if OrderInfoData.shared.complete == 2 {
                let start = self.tripInfo.trip[tip].stationOrder
                let end = self.tripInfo.trip[self.tripInfo.trip.count - 1].stationOrder
                var station = 0
                
                Train.shared.whileSuccessful = self.ignoreSuccess
                Train.shared.whileErrorOccurs = self.error
                
                Train.shared.getTrainInfo(id: self.tripInfo.trip[self.tripInfo.trip.count - 1].trainId) { info in
                    station = info.count
                }
                
                let departArrival = Order.shared.generateDepartArrival(stationCount: station, start: start, end: end)
                OrderInfoData.shared.order[1].departArrival = departArrival
            }
        }
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showTimeTable(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "Time Table Segue", sender: self)
    }
    
    @IBAction func addPassenger(_ sender: UIButton) {
        if Account.shared.isLogged {
            performSegue(withIdentifier: "Add Passenger List Segue", sender: self)
        } else {
            self.noticeInfo("Please login first")
        }
    }
    
    @IBAction func confirmOrder(_ sender: UIButton) {
        if OrderInfoData.shared.complete != 0 {
            var order = OrderInfoData.shared.order.removeFirst()
            order.departDate = OrderInfoData.shared.date
            order.passenger = OrderInfoData.shared.passenger
            
            Order.shared.whileSuccessful = { str, action in
                self.noticeSuccess("Order successfully")
            }
            
            Order.shared.whileErrorOccurs = error
            
            Order.shared.createOrder(order: order) { passenger in
                self.noticeError("\(passenger.name)'s seat has been taken")
            }
            
            OrderInfoData.shared.complete -= 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let timeTable = segue.destination as? TimeTableViewController {
            timeTable.trainInfo = tripInfo.trip
        }
    }
}

class OrderInfoData {
    static let shared = OrderInfoData()
    
    var order: [OrderElement] = []
    
    var passenger: [OrderPassenger] = []
    
    var complete = 1
    
    var date = ""
}
