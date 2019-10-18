//
//  LoginViewController.swift
//  train
//
//  Created by Ghost on 2018/9/17.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // Account login mode
    fileprivate static var login = "Login"
    fileprivate static var register = "Register"
    fileprivate var mode = LoginViewController.login
    
    // Update user name in profile view
    var userNameCallback: (String) -> () = { str in }
    
    // View component
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activationButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activationButton.layer.cornerRadius = 5.0
    }
    
    // Activation button listener
    @IBAction func executeAction(_ sender: UIButton) {
        
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        guard username != nil || username != "" else {
            self.noticeError("Please enter username", autoClear: true)
            return
        }
        
        guard password != nil || password != "" else {
            self.noticeError("Please enter password", autoClear: true)
            return
        }
        
        Account.shared.whileErrorOccurs = error
        Account.shared.whileSuccessful = success
        
        if mode == LoginViewController.login {
            Account.shared.login(user: username!, pass: password!, callback: userNameCallback)
        } else if mode == LoginViewController.register {
            Account.shared.register(user: username!, pass: password!, callback: userNameCallback)
        } else {
            return
        }
    }
    
    // Switch button listener
    @IBAction func changeMode(_ sender: UIButton) {
        if mode == LoginViewController.register {
            switchButton.setTitle(LoginViewController.register, for: UIControlState.normal)
            activationButton.setTitle(LoginViewController.login, for: UIControlState.normal)
            mode = LoginViewController.login
        } else if mode == LoginViewController.login {
            switchButton.setTitle(LoginViewController.login, for: UIControlState.normal)
            activationButton.setTitle(LoginViewController.register, for: UIControlState.normal)
            mode = LoginViewController.register
        }
    }
    
    // Cancel button listener
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// Keyboard behavior control
extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
