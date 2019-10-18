//
//  Networking.swift
//  train
//
//  Created by Ghost on 2018/9/11.
//  Copyright © 2018 Ghost. All rights reserved.
//

import Foundation
import Alamofire
import Reachability

public typealias NetworkingCallback = (Networking.Status, String?) -> ()

public class Networking {
    
    public enum Status: Int {
        case success = 200
        case dataError = 402
        case notLogin = 403
        case notFound = 404
        case alreadyExist = 405
        case parseError = 500
        case internalError = 501
    }
    
    /// Singleton
    public static let shared = Networking()
    
    // Session manager
    fileprivate var sessionManager: SessionManager
    
    // Cookie handle
    fileprivate var cookie: String
    // Connect host
    fileprivate let host = "http://192.144.150.162/"
    
    var reachable: Bool {
        if let reachability = Reachability() {
            return reachability.connection != .none
        } else {
            return false
        }
    }
    
    private init() {
        sessionManager =
            Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        if let cookie = UserDefaults.standard.string(forKey: "login_cookie") {
            print("cookie: \(cookie)")
            self.cookie = cookie
        } else {
            self.cookie = ""
        }
    }
    
    func get(path: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil,
             completion: @escaping NetworkingCallback) {
        let param = self.mergeCookie(parameters: parameters)
        print("request", "\(host)\(path)", param ?? "nil")
        sessionManager.request("\(host)\(path)", method: .get, parameters: param, headers: headers)
            .responseString() { (response) in
                self.statusHandler(data: response, callback: completion)
        }
    }
    
    func post(path: String, parameters: Parameters?, headers: HTTPHeaders? = nil,
              completion: @escaping NetworkingCallback) {
        let param = self.mergeCookie(parameters: parameters)
        print("request", "\(host)\(path)", param ?? "nil")
        sessionManager.request("\(host)\(path)", method: .post, parameters: param, headers: headers)
            .responseString() { (response) in
                self.statusHandler(data: response, callback: completion)
        }
    }
    
    fileprivate func statusHandler(data: DataResponse<String>, callback: @escaping NetworkingCallback) {
        
        if let headers = data.response?.allHeaderFields as? [String: String], let cookie = headers["Set-Cookie"] {
            if self.cookie != cookie {
                UserDefaults.standard.set(cookie, forKey: "login_cookie")
                self.cookie = cookie
            }
        }
        
        var status: Status = .parseError
        if let statusValue = data.value {
            status = Status.init(rawValue: statusValue.status()) ?? .parseError
            print("response", statusValue.status(), status, data.value?.substring(from: 3) ?? "nil")
        } else {
            print("response", data)
        }
        callback(status, data.value?.substring(from: 3) ?? nil)
    }
    
    fileprivate func mergeCookie(parameters: Parameters?) -> Parameters? {
        if self.cookie == "" {
            return parameters
        } else {
            let cookie = ["Cookie": self.cookie]
            if let param = parameters {
                return param.merging(cookie) { $1 }
            } else {
                return cookie
            }
        }
    }
}

/**
 *  Extension using for status process and useful utility
 */
public extension String {
    
    public func substring(to index: Int) -> String? {
        if self.count >= index {
            let toIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[self.startIndex..<toIndex]
            return String(subString)
        } else {
            return nil
        }
    }
    
    public func substring(from index: Int) -> String? {
        if self.count >= index {
            let fromIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[fromIndex..<self.endIndex]
            return String(subString)
        } else {
            return nil
        }
    }
    
    fileprivate func status() -> Int {
        if let statusString = self.substring(to: 3) {
            return Int(statusString) ?? 500
        } else {
            return 500
        }
    }
}

public extension String {
    var md5: String {
        let cStr = self.cString(using: String.Encoding.utf8);
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString();
        for i in 0 ..< 16 {
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        return md5String as String
    }
}
