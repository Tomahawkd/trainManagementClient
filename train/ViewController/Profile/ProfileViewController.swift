//
//  Profile.swift
//  train
//
//  Created by Ghost on 2018/9/17.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {

    @IBOutlet weak var infoTable: UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!

    fileprivate var localEdition: AccountInfo = Account.shared.copy
    
    fileprivate var displayMode = 0
    fileprivate let data = [["Unknown", "Male", "Female"], ["Individual", "Student"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localEdition = Account.shared.copy
        self.tableView.reloadData()
    }

    // Reading data behavior
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "InformationCell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

        if cell == nil {
            cell = UITableViewCell(style: .value2, reuseIdentifier: cellIdentifier)
            cell!.selectionStyle = .blue
        }

        switch indexPath.row {
        case 0:
            cell!.textLabel?.text = "Name"
            cell!.detailTextLabel?.text = localEdition.name

        case 1:
            cell!.textLabel?.text = "Gender"
            cell!.detailTextLabel?.text = localEdition.sex

        case 2:
            cell!.textLabel?.text = "Birthday"
            cell!.detailTextLabel?.text = localEdition.birthday

        case 3:
            cell!.textLabel?.text = "ID Number"
            cell!.detailTextLabel?.text = localEdition.id

        case 4:
            cell!.textLabel?.text = "Phone"
            cell!.detailTextLabel?.text = localEdition.phone

        case 5:
            cell!.textLabel?.text = "Ticket type"
            cell!.detailTextLabel?.text = localEdition.ticket

        default: break
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Account.shared.isLogged ? 6 : 0
    }
}

// Editing behavior
extension ProfileViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath)
            switch indexPath.row {
            case 0: fallthrough
            case 3: fallthrough
            case 4:
                generateInputView(label: cell?.textLabel?.text ?? "", oldValue: cell?.detailTextLabel?.text ?? "")
                
            case 1:
                displayMode = 0
                generatePickerView(label: cell?.textLabel?.text ?? "", oldValue: localEdition.rawSex)
            case 5:
                displayMode = 1
                generatePickerView(label: cell?.textLabel?.text ?? "", oldValue: localEdition.rawTicket)
                
            case 2:
                generateDatePickerView()
                
            default: break
            }
        }
    }
    
    fileprivate func generateInputView(label: String, oldValue: String) {
        var inputText = UITextField()
        let msgAlertCtr = UIAlertController.init(title: "Edit value", message: "Please input \(label)", preferredStyle: .alert)
        
        msgAlertCtr.addAction(UIAlertAction.init(title: "Confirm", style:.default) { (action) -> () in
            if let input = inputText.text {
                switch label {
                case "Name": self.localEdition.name = input
                case "ID Number":
                    if input.count == 18 {
                        self.localEdition.id = input
                    }
                case "Phone":
                    if input.count == 11 {
                        self.localEdition.phone = input
                    }
                default: break
                }
                self.tableView.reloadData()
            }
        })
        msgAlertCtr.addAction(UIAlertAction.init(title: "Cancel", style:.cancel) { (action) -> () in })
        msgAlertCtr.addTextField { (textField) in
            inputText = textField
            inputText.text = oldValue
            inputText.placeholder = "information"
        }
        self.present(msgAlertCtr, animated: true, completion: nil)
    }
    
    fileprivate func generatePickerView(label: String, oldValue: Int) {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // default
        pickerView.selectRow(oldValue, inComponent: 0, animated: true)
        let alertController = UIAlertController(title: "Please select \(label)\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            if self.displayMode == 0 {
                self.localEdition.rawSex = pickerView.selectedRow(inComponent: 0)
            } else {
                self.localEdition.rawTicket = pickerView.selectedRow(inComponent: 0)
            }
            self.tableView.reloadData()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel,handler: nil))
        pickerView.frame = CGRect(x: 0, y: 20, width: Int(UIScreen.main.bounds.width), height: 250)
        alertController.view.addSubview(pickerView)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func generateDatePickerView() {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .date
        
        // default
        let alertController = UIAlertController(title: "Please select birthday\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.localEdition.birthday = dateFormatter.string(from: pickerView.date)
            self.tableView.reloadData()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel,handler: nil))
        pickerView.frame = CGRect(x: 0, y: 20, width: Int(UIScreen.main.bounds.width), height: 250)
        alertController.view.addSubview(pickerView)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func editData(_ sender: UIBarButtonItem) {
        Account.shared.whileSuccessful = { str, action in
            self.noticeSuccess(str)
            self.localEdition = Account.shared.copy
            self.tableView.reloadData()
            self.dismiss(animated: true, completion: nil)
        }
        Account.shared.whileErrorOccurs = error
        
        if Account.shared.isLogged {
            // Commit Edit
            Account.shared.saveProfile(info: self.localEdition)
        } else {
            self.noticeError("Please login first")
        }
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data[displayMode].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[displayMode][row]
    }
    
    
}
