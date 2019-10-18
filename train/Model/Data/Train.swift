//
//  Train.swift
//  train
//
//  Created by Ghost on 2018/9/14.
//  Copyright © 2018 Ghost. All rights reserved.
//

import Foundation

struct TrainElement: Codable {
    var trainId: String
    var depart: String
    var arrival: String
    var stationCount: Int
    var seatCount: Int
    
    enum CodingKeys: String, CodingKey {
        case trainId = "train_id"
        case depart
        case arrival
        case stationCount = "station_count"
        case seatCount = "seat_count"
    }
    
    static var empty: TrainElement {
        return TrainElement(trainId: "", depart: "", arrival: "", stationCount: 0, seatCount: 0)
    }
}

struct TrainInfo: Codable {
    var trainId: String
    var stationOrder: Int
    var station: String
    var arrivalTime: String?
    var departTime: String?
    
    enum CodingKeys: String, CodingKey {
        case trainId = "train_id"
        case stationOrder = "station_order"
        case station
        case arrivalTime = "arrival_time"
        case departTime = "depart_time"
    }
    
    static var empty: TrainInfo {
        return TrainInfo(trainId: "", stationOrder: 0, station: "", arrivalTime: nil, departTime: nil)
    }
}

struct Trip: Codable {
    var title: String
    var trip: [TrainInfo]
    
    static var empty: Trip {
        return Trip(title: "", trip: [TrainInfo.empty])
    }
}

class Train: StatusHandle {
    
    public static var shared = Train()
    
    func getPages(callback: @escaping (Int) ->()) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        Networking.shared.get(path: "train/pages") { (status, pages) in
            if status == .success {
                if let pages = Int(pages ?? "N") {
                    callback(pages)
                    self.successHandler("", Train.pageAction)
                } else {
                    self.errorHandler(self.getErrorMessage(status: .parseError, actionType: Train.pageAction))
                }
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Train.pageAction))
            }
        }
    }
    
    func refreshTrainList(page: Int, callback: @escaping ([TrainElement]) -> ()) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        Networking.shared.get(path: "train/info/\(page)") { (status, json) in
            if status == .success {
                if let jsonData = json?.data(using: .utf8),
                    let train = try? JSONDecoder().decode([TrainElement].self, from: jsonData) {
                    callback(train)
                    self.successHandler("", Train.adminTrainAction)
                } else {
                    self.errorHandler(self.getErrorMessage(status: .parseError, actionType: Train.adminTrainAction))
                }
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Train.adminTrainAction))
            }
        }
    }
    
    func getTrainInfo(id: String, callback: @escaping ([TrainInfo]) -> ()) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        Networking.shared.get(path: "train/id/\(id)") { (status, json) in
            if status == .success {
                if let jsonData = json?.data(using: .utf8),
                    let train = try? JSONDecoder().decode([TrainInfo].self, from: jsonData) {
                        callback(train.sorted() { $0.stationOrder < $1.stationOrder })
                        self.successHandler("", Train.infoAction)
                } else {
                    self.errorHandler(self.getErrorMessage(status: .parseError, actionType: Train.infoAction))
                }
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Train.infoAction))
            }
        }
    }
    
    func getTrip(start: String, end: String, callback: @escaping ([Trip]?) -> ()) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        if let path = "train/routine/\(start)/\(end)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            Networking.shared.get(path: path) { (status, json) in
                if status == .success {
                    if let jsonData = json?.data(using: .utf8),
                        let trip = try? JSONDecoder().decode([Trip].self, from: jsonData) {
                        callback(trip.sorted() { $0.trip[0].departTime ?? "" < $1.trip[0].departTime ?? "" })
                        self.successHandler("", Train.tripAction)
                    } else {
                        self.errorHandler(self.getErrorMessage(status: .parseError, actionType: Train.tripAction))
                    }
                } else {
                    self.errorHandler(self.getErrorMessage(status: status, actionType: Train.tripAction))
                }
            }
        } else {
            self.errorHandler("Invalid Station")
        }
    }
    
    internal override func getErrorMessage(status: Networking.Status, actionType: Int) -> String {
        switch status {
        case .notLogin: return "You must login first"
        case .notFound:
            if actionType == Train.infoAction {
                return "Train not found"
            } else if actionType == Train.tripAction {
                return "Train not found"
            } else {
                return ""
            }
        case .internalError: return "Server data error"
        case .parseError: return "Data parse error"
        case .dataError: return "Data invalid"
        case .alreadyExist: return ""
        case .success: return ""
        }
    }
}

extension Train {
    public static let infoAction = 0
    public static let tripAction = 1
    public static let pageAction = 2
    public static let adminTrainAction = 3
}
