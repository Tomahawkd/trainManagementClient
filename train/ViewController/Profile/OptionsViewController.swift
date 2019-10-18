//
//  OptionsViewController.swift
//  train
//
//  Created by Ghost on 2018/9/11.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class OptionsViewController: UITableViewController {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImg: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Account.shared.accountRole != Account.anonymous {
            Account.shared.whileErrorOccurs = { str in
                Account.shared.logout()
                self.noticeError("Please re-login")
            }
            Account.shared.refreshProfile() { name in self.userName.text = name }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                if !Account.shared.isLogged {
                    performSegue(withIdentifier: "Login View Segue", sender: self)
                } else {
                    performSegue(withIdentifier: "Profile Segue", sender: self)
                }

            case 1:
                performSegue(withIdentifier: "About View Segue", sender: self)
            default: break
            }
        }
    }

    // Update User Name
    override func viewWillAppear(_ animated: Bool) {
        self.userName.text = Account.shared.user
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loginViewController = segue.destination as? LoginViewController {
            loginViewController.userNameCallback = { str in self.userName.text = str }
        }
    }
}
