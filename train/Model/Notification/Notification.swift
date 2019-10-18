//
//  Notification.swift
//  train
//
//  Created by Ghost on 2018/9/13.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

public typealias ErrorMessageCallback = (String) -> ()
public typealias CompletionCallback = (String, Int) -> ()

protocol Notifiable {
    
    var whileSuccessful: CompletionCallback { get set }
    
    var whileErrorOccurs: ErrorMessageCallback { get set }
    
    func getErrorMessage(status: Networking.Status, actionType: Int) -> String
}

protocol CallbackFunctions {
    var success: CompletionCallback { get }
    var error: ErrorMessageCallback { get }
}

extension UIViewController: CallbackFunctions {
    
    var success: CompletionCallback {
        return { str, action in
            self.noticeSuccess(str)
            self.dismiss(animated: true, completion: nil)
        }
    }
    var error: ErrorMessageCallback {
        return { str in self.noticeError(str) }
    }
    
    var ignoreSuccess: CompletionCallback {
        return { str, action in }
    }
    
    var ignoreError: ErrorMessageCallback {
        return { str in }
    }
}
