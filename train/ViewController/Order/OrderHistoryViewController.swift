//
//  OrderHistoryViewController.swift
//  train
//
//  Created by Ghost on 2018/9/20.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class OrderHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var orderList = [OrderOutline.empty]
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Order History Cell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            cell!.selectionStyle = .none
        }
        
        cell!.textLabel?.text = "\(orderList[indexPath.row].trainId)\t\t\tDepart Date: \(orderList[indexPath.row].departDate)"
        cell!.detailTextLabel?.text = """
        Create Date: \(orderList[indexPath.row].createDate)\tAmount: ¥\(orderList[indexPath.row].price)
        """
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Order detailed Segue", sender: orderList[indexPath.row])
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detail = segue.destination as? OrderDetailViewController,
            let sender = sender as? OrderOutline {
            
            let _ = detail.view
            Order.shared.whileSuccessful = ignoreSuccess
            Order.shared.whileErrorOccurs = error
            
            Order.shared.getOrderInfo(id: sender.orderId) { order in
                detail.order = order
                detail.generateData()
                detail.tableView.reloadData()
            }
        }
    }
}

