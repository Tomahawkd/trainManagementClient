//
//  Account.swift
//  train
//
//  Created by Ghost on 2018/9/11.
//  Copyright © 2018 Ghost. All rights reserved.
//

import Foundation

/**
 * Account information
 */
struct AccountInfo: Codable, Equatable {

    var userId: String
    var name: String?
    var rawSex: Int
    var birthday: String?
    var id: String?
    var phone: String?
    var rawTicket: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case rawSex = "sex"
        case birthday
        case id = "id_number"
        case phone
        case rawTicket = "ticket_type"
    }
    
    var sex: String {
        get {
            if self.rawSex == 1 {
                return "Male"
            } else if self.rawSex == 2 {
                return "Female"
            } else {
                return "Unknown"
            }
        }
        set {
            if newValue == "Male" {
                self.rawSex = 1
            } else if newValue == "Female" {
                self.rawSex = 2
            } else {
                self.rawSex = 0
            }
        }
    }
    
    var ticket: String {
        get {
            if self.rawTicket == 1 {
                return "Student"
            } else {
                return "Individual"
            }
            
        }
        set {
            if newValue == "Student" {
                self.rawTicket = 1
            } else {
                self.rawTicket = 0
            }
        }
    }
    
    static var empty: AccountInfo {
        return AccountInfo(userId: "Login", name: nil, rawSex: 0, birthday: nil, id: nil, phone: nil, rawTicket: 0)
    }
    
    public static func == (lhs: AccountInfo, rhs: AccountInfo) -> Bool {
        return lhs.userId == rhs.userId &&
            lhs.name == rhs.name &&
            lhs.rawSex == rhs.rawSex &&
            lhs.birthday == rhs.birthday &&
            lhs.id == rhs.id &&
            lhs.phone == rhs.phone
    }
}

class Account: StatusHandle {

    // Singleton variable //
    public static let shared = Account()
    
    /// Role Code ///
    public static let anonymous = -1
    public static let user = 0
    public static let admin = 1
    /// end
    
    /// Stored Properties ///
    // Account Properties
    private var info: AccountInfo?
    // new instance of info
    var copy: AccountInfo {
        if let info = info {
            return AccountInfo(userId: info.userId,
                               name: info.name, rawSex: info.rawSex,
                               birthday: info.birthday, id: info.id,
                               phone: info.phone, rawTicket: info.rawTicket)
        } else {
            return AccountInfo.empty
        }
    }
    /// end

    /// Compute Properties ///
    // Account status
    var isLogged: Bool { return info != nil }
    // Account role
    var accountRole: Int {
        return Int(UserDefaults.standard.string(forKey: "login_role") ?? "N") ?? Account.anonymous
    }
    
    internal required override init() {
        info = nil
        super.init()
        self.refreshProfile() { str in }
    }

    public func login(user: String, pass: String, callback: @escaping (String) -> ()) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        let data = ["username": user, "password": pass.md5]
        Networking.shared.post(path: "account/login", parameters: data) { (status, role) in
            if status == .success {
                UserDefaults.standard.set(Int(role ?? "N") ?? -1, forKey: "login_role")
                self.refreshProfile(callback)
                self.successHandler("Login successfully", Account.loginAction)
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Account.loginAction))
            }
        }
    }
    
    public func register(user: String, pass: String, callback: @escaping (String) -> ()) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        let data = ["username": user, "password": pass.md5]
        Networking.shared.post(path: "account/register", parameters: data) { (status, _) in
            if status == .success {
                UserDefaults.standard.set(0, forKey: "login_role")
                self.refreshProfile(callback)
                self.successHandler("Register successfully", Account.registerAction)
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Account.registerAction))
            }
        }
    }
    
    public func refreshProfile(_ callback: @escaping (String) -> ()) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        Networking.shared.get(path: "account/info") { (status, json) in
            if status == .success {
                if let jsonData = json?.data(using: .utf8) {
                    self.info = try? JSONDecoder().decode(AccountInfo.self, from: jsonData)
                    callback(self.user)
                    self.successHandler("", Account.infoAction)
                } else {
                    self.errorHandler(self.getErrorMessage(status: .parseError, actionType: Account.infoAction))
                }
            } else {
                if status == .notLogin {
                    UserDefaults.standard.set(-1, forKey: "login_role")
                    UserDefaults.standard.set(nil, forKey: "login_cookie")
                }
                self.errorHandler(self.getErrorMessage(status: status, actionType: Account.infoAction))
            }
        }
    }
    
    public func saveProfile(info: AccountInfo) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        if info == self.info {
            self.successHandler("Edit successfully", Account.editAction)
            return
        }
        if !checkInfo(info) {
            self.errorHandler(self.getErrorMessage(status: .dataError, actionType: Account.editAction))
        }
        if let data = try? JSONEncoder().encode(info),
            let str = String(data: data, encoding: .utf8) {
            Networking.shared.post(path: "account/edit", parameters: ["data": str]) { (status, _) in
                if status == .success {
                    self.refreshProfile({ str in })
                    self.successHandler("Edit successfully", Account.editAction)
                } else {
                    self.errorHandler(self.getErrorMessage(status: status, actionType: Account.editAction))
                }
            }
            return
        } else {
            self.errorHandler(self.getErrorMessage(status: .parseError, actionType: Account.editAction))
        }
    }
    
    fileprivate func checkInfo(_ info: AccountInfo) -> Bool {
        
        guard info.id?.count == 18 else {
            return false
        }
        
        guard info.phone?.count == 11 else {
            return false
        }
        
        guard info.birthday?.split(separator: "-").count == 2 else {
            return false
        }
        
        return true
    }
    
    public func editPassword(old: String, new: String) {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        let data = ["old": old.md5, "new": new.md5]
        Networking.shared.post(path: "account/passwd", parameters: data) { (status, _) in
            if status == .success {
                self.successHandler("Change successful", Account.passwdAction)
            } else {
                self.errorHandler(self.getErrorMessage(status: status, actionType: Account.passwdAction))
            }
        }
    }
    
    public func logout() {
        guard Networking.shared.reachable else {
            self.errorHandler("No network")
            return
        }
        
        Networking.shared.get(path: "account/logout") { (status, _) in }
        info = nil
        UserDefaults.standard.set(-1, forKey: "login_role")
    }
    
    internal override func getErrorMessage(status: Networking.Status, actionType type: Int) -> String {
        switch status {
        case .notLogin: return "You must login"
        case .alreadyExist: return "Username has already been taken"
        case .notFound:
            if type == Account.loginAction { return "User or password error" }
            else if type == Account.passwdAction { return "Password error" }
            else { return "" }
        case .internalError: return "Server data error"
        case .dataError: return "Data invalid"
        case .parseError: return "Data parse error"
        case .success: return ""
        }
    }
}

/**
 * Action List
 */
extension Account {

    public static let loginAction = 0
    public static let infoAction = 1
    public static let editAction = 2
    public static let passwdAction = 3
    public static let registerAction = 4
    public static let logoutAction = 5
}

/**
 *  Account Properties
 */
extension Account {
    var user: String {
        get { return info?.userId ?? "Login"}
    }
    var name: String {
        get { return info?.name ?? "" }
        set { if isLogged { info?.name = newValue } }
    }
    var sex: String {
        get { return info?.sex ?? "" }
        set { if isLogged { info?.sex = newValue } }
    }
    var birthday: String {
        get { return info?.birthday ?? "" }
        set { if isLogged { info?.birthday = newValue } }
    }
    var id: String {
        get { return info?.id ?? "" }
        set { if isLogged { info?.id = newValue } }
    }
    var phone: String {
        get { return info?.phone ?? "" }
        set { if isLogged { info?.phone = newValue } }
    }
    var ticket: String {
        get { return info?.ticket ?? "" }
        set { if isLogged { info?.ticket = newValue } }
    }
}
