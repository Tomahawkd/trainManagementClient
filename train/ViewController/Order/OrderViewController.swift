//
//  OrderViewController.swift
//  train
//
//  Created by Ghost on 2018/9/20.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class OrderViewController: UITableViewController {
    
    fileprivate var mode = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateData()
    }
    
    fileprivate func updateData() {
        if Account.shared.isLogged {
            Order.shared.whileSuccessful = ignoreSuccess
            Order.shared.whileErrorOccurs = error
            Order.shared.refreshOrderList()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Account.shared.isLogged else {
            self.noticeInfo("Please login first")
            return
        }
        
        if indexPath.section == 0 {
            if [0, 1, 2].contains(indexPath.row) {
                self.mode = indexPath.row
                self.performSegue(withIdentifier: "Order History Segue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let orderHistoryViewController = segue.destination as? OrderHistoryViewController {
            
            var data: [OrderOutline] = []
            switch mode {
            case 0: data = Order.shared.orderList
            case 1:
                for order in Order.shared.orderList {
                    if order.status == 0 {
                        data.append(order)
                    }
                }
            case 2:
                let dformat = DateFormatter()
                dformat.dateFormat = "yyyy-MM-dd"
                let today = dformat.string(from: Date())
                for order in Order.shared.orderList {
                    if order.departDate <-- today {
                        data.append(order)
                    }
                }
            default: break
            }
            orderHistoryViewController.orderList = data
        }
    }
}

infix operator <--=
infix operator =-->
infix operator <--

extension String {
    static func <--=(_ lhs: String, _ rhs: String) -> Bool {
        let left = Int(lhs.replacingOccurrences(of: "-", with: "")) ?? 0
        let right = Int(rhs.replacingOccurrences(of: "-", with: "")) ?? 1
        return left <= right
    }
    
    static func =-->(_ lhs: String, _ rhs: String) -> Bool {
        let left = Int(lhs.replacingOccurrences(of: "-", with: "")) ?? 0
        let right = Int(rhs.replacingOccurrences(of: "-", with: "")) ?? 1
        return left >= right
    }
    
    static func <--(_ lhs: String, _ rhs: String) -> Bool {
        let left = Int(lhs.replacingOccurrences(of: "-", with: "")) ?? 0
        let right = Int(rhs.replacingOccurrences(of: "-", with: "")) ?? 1
        return left < right
    }
}
