//
//  Order.swift
//  train
//
//  Created by Ghost on 2018/9/14.
//  Copyright © 2018 Ghost. All rights reserved.
//

import Foundation

struct OrderOutline: Codable {
    var orderId: Int
    var createDate: String
    var departDate: String
    var status: Int
    var trainId: String
    var price: Int
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case createDate = "create_date"
        case departDate = "depart_date"
        case status
        case trainId = "train_id"
        case price
    }
    
    static var empty: OrderOutline {
        return OrderOutline(orderId: 0, createDate: "", departDate: "", status: -1, trainId: "0", price: 0)
    }
}

struct OrderElement: Codable {
    
    var orderId: Int
    var createDate: String
    var departDate: String
    var status: Int
    var trainId: String
    var departArrival: Int
    var price: Int
    var passenger: [OrderPassenger]
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case createDate = "create_date"
        case departDate = "depart_date"
        case status
        case trainId = "train_id"
        case departArrival = "depart_arrival"
        case price
        case passenger
    }
    
    static var empty: OrderElement {
        return OrderElement(orderId: 0, createDate: "", departDate: "", status: 0, trainId: "", departArrival: 0, price: 0, passenger: [])
    }
}

struct OrderPassenger: Codable, Equatable {
    
    var seatId: Int
    var name: String
    var passengerId: String
    var ticketType: Int
    
    enum CodingKeys: String, CodingKey {
        case seatId = "seat_id"
        case name = "passenger"
        case passengerId = "passenger_id"
        case ticketType = "ticket_type"
    }
    
    var seat: (Int, Int, Int) {
        get {
            let s = seatId
            let divider = seatId <= 20 ? 4 : 5
            return (s / 80 + 1, (s % 80) / divider + 1, (s % 80) % divider + 1)
        }
        set {
            let (carbin, line, seat) = newValue
            
            if carbin == 1 && line <= 5 {
                seatId = (line - 1) * 4 + seat - 1
            } else {
                seatId = (line - 1) * 5 + seat - 1 + (carbin - 1) * 80
            }
        }
    }
    
    var ticket: String {
        get {
            if self.ticketType == 1 {
                return "Student"
            } else {
                return "Individual"
            }
            
        }
        set {
            if newValue == "Student" {
                self.ticketType = 1
            } else {
                self.ticketType = 0
            }
        }
    }
    
    public static func ==(_ lhs: OrderPassenger, _ rhs: OrderPassenger) -> Bool {
        return lhs.seatId == rhs.seatId &&
                lhs.passengerId == rhs.passengerId
    }
}

class Order: StatusHandle {
    
    public static var shared = Order()
    
    private var list = [OrderOutline.empty]
    var orderList : [OrderOutline] {
        return list
    }
    
    func refreshOrderList() {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        Networking.shared.get(path: "ticket/list") { status, json in
            if status == .success {
                if let jsonData = json?.data(using: .utf8),
                    let order = try? JSONDecoder().decode([OrderOutline].self, from: jsonData) {
                    self.list = order
                    self.successHandler("", Order.listAction)
                } else {
                    self.errorHandler(self.getErrorMessage(status: .parseError, actionType: Order.listAction))
                }
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Order.listAction))
            }
        }
    }
    
    func getOrderInfo(id: Int, callback: @escaping (OrderElement) -> ()) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        Networking.shared.get(path: "ticket/id/\(id)") { status, json in
            if status == .success {
                if let jsonData = json?.data(using: .utf8),
                    let order = try? JSONDecoder().decode(OrderElement.self, from: jsonData) {
                    callback(order)
                    self.successHandler("", Order.infoAction)
                } else {
                    self.errorHandler(self.getErrorMessage(status: .parseError, actionType: Order.infoAction))
                }
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Order.infoAction))
            }
        }
    }
    
    func createOrder(order: OrderElement, callback: @escaping (OrderPassenger) -> ()) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        if let data = try? JSONEncoder().encode(order),
            let str = String(data: data, encoding: .utf8) {
            Networking.shared.post(path: "ticket/order", parameters: ["data": str]) { (status, info) in
                if status == .success {
                    self.successHandler("Order successfully", Order.createAction)
                } else if status == .alreadyExist {
                    if let jsonData = info?.data(using: .utf8),
                        let order = try? JSONDecoder().decode(OrderPassenger.self, from: jsonData) {
                        callback(order)
                    }
                } else {
                    self.errorHandler(self.getErrorMessage(status: status, actionType: Order.createAction))
                }
            }
            return
        } else {
            self.errorHandler(self.getErrorMessage(status: .parseError, actionType: Order.createAction))
        }
    }
    
    func comfirm(order: Int) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        Networking.shared.post(path: "ticket/payment", parameters: ["order_id": order]) { status, _ in
            if status == .success {
                self.successHandler("Pay successfully", Order.comfirmAction)
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Order.comfirmAction))
            }
        }
    }
    
    func editOrder(id: Int, date: String) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        Networking.shared.post(path: "ticket/change", parameters: ["order_id": id, "date": date]) { status, _ in
            if status == .success {
                self.successHandler("", Order.editAction)
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Order.editAction))
            }
        }
    }
    
    func refundOrder(id: Int) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        Networking.shared.post(path: "ticket/refund", parameters: ["order_id": id]) { status, _ in
            if status == .success {
                self.successHandler("", Order.refundAction)
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Order.refundAction))
            }
        }
    }
    
    func remainTicket(train: String, date: String, departArrival: Int, callback: @escaping ([Int]) -> ()) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        let param = ["train": train, "date": date, "trip": String(departArrival)]
        Networking.shared.post(path: "ticket/remain", parameters: param) { status, remain in
            if status == .success {
                if let jsonData = remain?.data(using: .utf8),
                    let order = try? JSONDecoder().decode([Int].self, from: jsonData) {
                    callback(order)
                    self.successHandler("", Order.remainAction)
                } else {
                    self.errorHandler(self.getErrorMessage(status: .parseError, actionType: Order.remainAction))
                }
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Order.remainAction))
            }
        }
    }
    
    internal override func getErrorMessage(status: Networking.Status, actionType: Int) -> String {
        switch status {
        case .alreadyExist:
            if actionType == Order.createAction { return "Seat has already been taken" }
            else if actionType == Order.comfirmAction { return "Already payed" }
            else  { return "" }
        case .dataError: return "Data invalid"
        case .internalError: return "Server Data Error"
        case .notFound:
            if actionType == Order.listAction { return "No order found" }
            else if actionType == Order.infoAction ||
                actionType == Order.comfirmAction ||
                actionType == Order.editAction ||
                actionType == Order.refundAction {
                return "Order not found"
            } else if actionType == Order.remainAction { return "Train not found" }
            else { return "" }
        case .notLogin: return "You must login first"
        case .parseError: return "Data parse error"
        case .success: return ""
        }
    }
}

extension Order {
    public static let listAction = 0
    public static let infoAction = 1
    public static let createAction = 2
    public static let editAction = 3
    public static let refundAction = 4
    public static let remainAction = 5
    public static let comfirmAction = 6
    
    public func getStationIndex(stationCount: Int, departArrival: Int) -> (Int, Int) {
        var temp = departArrival
        var arrivalIndex = 0
        var departIndex = 1
        var status = 1
        for i in stride(from: stationCount, to: 0, by: -1)  {
            if temp & 1 == 1 {
                if status == 1 {
                    arrivalIndex = i
                    status = 0
                }
            } else {
                if status == 0 {
                    departIndex = i + 1
                    break
                }
            }
            temp >>= 1
        }
        return (departIndex, arrivalIndex)
    }
    
    public func generateDepartArrival(stationCount: Int, start: Int, end: Int) -> Int {
        var basis = 0
        for i in 0...stationCount {
            basis <<= 1
            if i >= start && i <= end {
                basis += 1
            }
        }
        return basis
    }
}



