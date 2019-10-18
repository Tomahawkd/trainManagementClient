//
//  TrainManagementViewController.swift
//  train
//
//  Created by Ghost on 2018/9/19.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class TrainManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var pageItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var currentPage = 1
    var pageCount = 1
    var train = [TrainElement.empty]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateData()
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func previousPage(_ sender: UIButton) {
        if currentPage == 1 {
            self.noticeInfo("This is the first page")
        } else {
            self.currentPage -= 1
            self.updateData()
        }
    }

    @IBAction func nextPage(_ sender: UIButton) {
        if currentPage == pageCount {
            self.noticeInfo("This is last page")
        } else {
            self.currentPage += 1
            self.updateData()
        }
    }
    
    func updateData() {
        Train.shared.whileSuccessful = ignoreSuccess
        Train.shared.whileErrorOccurs = error
        
        Train.shared.getPages() { pages in
            self.pageCount = pages
        }
        
        Train.shared.refreshTrainList(page: currentPage) { (data) in
            self.train = data
            self.tableView.reloadData()
            self.pageItem.title = "\(self.currentPage) of \(self.pageCount)"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Train Information Cell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .value2, reuseIdentifier: cellIdentifier)
            cell!.selectionStyle = .default
        }
        
        cell!.textLabel?.text = train[indexPath.row].trainId
        cell!.detailTextLabel?.text = "\(train[indexPath.row].depart)-\(train[indexPath.row].arrival)"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return train.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
    }
}
