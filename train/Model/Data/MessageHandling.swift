//
//  ErrorHandling.swift
//  train
//
//  Created by Ghost on 2018/9/14.
//  Copyright © 2018 Ghost. All rights reserved.
//

import Foundation

class StatusHandle: Notifiable {
    
    internal var successHandler: CompletionCallback
    internal var errorHandler: ErrorMessageCallback
    
    var whileSuccessful: CompletionCallback {
        get { return self.successHandler }
        set { self.successHandler = newValue }
    }
    
    var whileErrorOccurs: ErrorMessageCallback {
        get { return self.errorHandler }
        set { self.errorHandler = newValue }
    }
    
    init() {
        errorHandler = { str in }
        successHandler = { str, action in }
    }
    
    internal func getErrorMessage(status: Networking.Status, actionType: Int) -> String {
        return ""
    }
}
