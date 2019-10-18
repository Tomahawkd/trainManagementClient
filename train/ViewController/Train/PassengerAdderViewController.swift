//
//  PassengerAdderViewController.swift
//  train
//
//  Created by Ghost on 2018/9/21.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class PassengerAdderViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var seatCount = 0
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var seatPicker: UIPickerView!
    @IBOutlet weak var ticketPicker: UIPickerView!
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPassenger(_ sender: UIBarButtonItem) {
        let id = idTextField.text ?? ""
        guard id.count == 18 else {
            self.noticeError("ID invalid")
            return
        }
        var pass = OrderPassenger(seatId: 0, name: nameTextField.text ?? "", passengerId: idTextField.text ?? "", ticketType: 0)
        pass.seat = (seatPicker.selectedRow(inComponent: 0) + 1, seatPicker.selectedRow(inComponent: 1) + 1, seatPicker.selectedRow(inComponent: 2) + 1)
        pass.ticketType = ticketPicker.selectedRow(inComponent: 0)
        OrderInfoData.shared.passenger.append(pass)
        dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.isEqual(seatPicker) {
            return 3
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.isEqual(seatPicker) {
            switch component {
            case 0: return 2
            case 1: return 16
            case 2: return 5
            default: return 0
            }
        } else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.isEqual(seatPicker) {
            return "\(row + 1)"
        } else {
            switch row {
            case 0: return "Individual"
            case 1: return "Student"
            default: return ""
            }
        }
    }
}

extension PassengerAdderViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" || string == "\r" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
