//
//  OrderDetailViewController.swift
//  train
//
//  Created by Ghost on 2018/9/20.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class OrderDetailViewController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var departLabel: UILabel!
    @IBOutlet weak var createLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var payButton: UIButton!
    
    var order: OrderElement?
    var trainInfo: [TrainInfo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        payButton.isEnabled = false
        payButton.layer.cornerRadius = 5.0
        payButton.backgroundColor = .gray
        self.tableView.register(TripleInfoCell.self, forCellReuseIdentifier: "Passenger View Cell")
        
        if order?.status == 0 {
            payButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if order?.status == 0 {
            payButton.isEnabled = true
            payButton.backgroundColor = UIColor(red: CGFloat(0), green: CGFloat(0.5), blue: CGFloat(1.0), alpha: CGFloat(1.0))
        }
    }
    
    func generateData() {
        self.noticeInfo("Loading", autoClear: false)
        if let order = order {
            self.departLabel.text = "Depart Date: \(order.departDate)"
            self.createLabel.text = "Create Date: \(order.createDate)"
            
            Train.shared.whileSuccessful = ignoreSuccess
            Train.shared.whileErrorOccurs = { str in
                self.titleLabel.text = order.trainId
                self.clearAllNotice()
                self.noticeError("Data not gathered")
            }
            
            Train.shared.getTrainInfo(id: order.trainId) { info in
                let i = Order.shared.getStationIndex(stationCount: info.count,
                                                                departArrival: order.departArrival)
                let (start, end) = i
                self.trainInfo = Array(info[start-1...end-1])
                self.titleLabel.text = "\(info[start-1].station)---\(order.trainId)---\(info[end-1].station)"
                
                self.clearAllNotice()
            }
        } else {
            self.clearAllNotice()
            titleLabel.text = ""
            departLabel.text = "Depart Date: "
            createLabel.text = "Create Date: "
            self.noticeError("Data not gathered")
        }
    }
    
    @IBAction func pay(_ sender: UIButton) {
        if order?.status == 0 {
            
            Order.shared.whileSuccessful = { str, action in
                self.noticeSuccess("Pay successfully")
            }
            Order.shared.whileErrorOccurs = error
            
            Order.shared.comfirm(order: order?.orderId ?? 0)
        }
    }
    
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editOrder(_ sender: UIBarButtonItem) {
        let dformat = DateFormatter()
        dformat.dateFormat = "yyyy-MM-dd"
        let today = dformat.string(from: Date())
        
        if let order = order {
            if today <--= order.departDate {
                let pickerView = UIDatePicker()
                pickerView.datePickerMode = .date
                
                let alertController = UIAlertController(title: "Edit Order\n\n\n\n\n\n\n\n\n\n\n\n",
                                                        message: nil, preferredStyle: .actionSheet)
                alertController.addAction(UIAlertAction(title: "Edit", style: .default) { (alertAction) -> Void in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let date = dateFormatter.string(from: pickerView.date)
                    
                    if today <--= date {
                        
                        Order.shared.whileSuccessful = { str, action in
                            if action == Order.editAction {
                                Order.shared.whileSuccessful = self.ignoreSuccess
                                Order.shared.whileErrorOccurs = self.error
                                
                                Order.shared.getOrderInfo(id: order.orderId) { order in
                                    self.order = order
                                    self.generateData()
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        
                        Order.shared.editOrder(id: order.orderId, date: date)
                    }
                })
                alertController.addAction(UIAlertAction(title: "Refund", style: .default) { (alertAction) -> Void in
                    let msgAlertCtr = UIAlertController.init(title: "Refund", message: "Do you want to have a refund?", preferredStyle: .alert)
                    msgAlertCtr.addAction(UIAlertAction.init(title: "Confirm", style:.default) { (action) -> () in
                        if order.departDate <--= today {
                            Order.shared.whileSuccessful = { str, action in
                                if action == Order.refundAction {
                                    self.noticeSuccess("Order refunded")
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                            Order.shared.whileErrorOccurs = self.error
                        
                            Order.shared.refundOrder(id: order.orderId)
                        } else {
                            self.noticeError("Already out of date")
                        }
                    })
                    msgAlertCtr.addAction(UIAlertAction.init(title: "Cancel", style:.cancel) { (action) -> () in })
                    self.present(msgAlertCtr, animated: true, completion: nil)
                })
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
                pickerView.frame = CGRect(x: 0, y: 20, width: Int(UIScreen.main.bounds.width), height: 250)
                alertController.view.addSubview(pickerView)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func tripDetail(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "Order Trip Segue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order?.passenger.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Passenger View Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TripleInfoCell
        
        if cell == nil {
            cell = TripleInfoCell(style: .default, reuseIdentifier: cellIdentifier)
            cell!.selectionStyle = .none
        }
        
        cell?.setData(order!.passenger[indexPath.row].name,
                      order!.passenger[indexPath.row].passengerId,
                      order!.passenger[indexPath.row].ticket)
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let trip = segue.destination as? OrderTripViewController, let tripInfo = trainInfo {
            trip.tripInfo = tripInfo
        }
    }
}
