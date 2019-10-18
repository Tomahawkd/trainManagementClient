//
//  AccountViewController.swift
//  train
//
//  Created by Ghost on 2018/9/17.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class AccountViewController: UITableViewController {
    
    @IBAction func logout(_ sender: UIButton) {
        Account.shared.logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "Profile Edit Segue", sender: self)
                
            case 1:
                performSegue(withIdentifier: "Password Edit Segue", sender: self)
        
            default: break
            }
        }
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
