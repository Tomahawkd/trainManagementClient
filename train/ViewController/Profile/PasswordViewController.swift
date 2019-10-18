//
//  PasswordEditController.swift
//  train
//
//  Created by Ghost on 2018/9/17.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBAction func changePassword(_ sender: UIButton) {
        let old = oldPasswordTextField.text
        let new = newPasswordTextField.text
        
        guard old != nil || old != "" else {
            self.noticeError("Please enter old password", autoClear: true)
            return
        }
        
        guard new != nil || new != "" else {
            self.noticeError("Please enter new password", autoClear: true)
            return
        }
        
        Account.shared.whileSuccessful = success
        Account.shared.whileErrorOccurs = error
        
        if Account.shared.isLogged {
            Account.shared.editPassword(old: old!, new: new!)
        } else {
            self.noticeError("Please login first")
        }
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
