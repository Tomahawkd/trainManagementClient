//
//  PassengerInfoCell.swift
//  train
//
//  Created by Ghost on 2018/9/21.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit

class TripleInfoCell: UITableViewCell {
    
    var firstLabel: UILabel = UILabel()
    var secondLabel: UILabel = UILabel()
    var thirdLabel: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    fileprivate func setUp() {
        firstLabel.frame = CGRect(x: 15, y: 12, width: 90, height: 20)
        firstLabel.adjustsFontSizeToFitWidth = true
        firstLabel.textAlignment = .center
        secondLabel.frame = CGRect(x: 142, y: 12, width: 90, height: 20)
        secondLabel.adjustsFontSizeToFitWidth = true
        secondLabel.textAlignment = .center
        thirdLabel.frame = CGRect(x: 270, y: 12, width: 90, height: 20)
        thirdLabel.adjustsFontSizeToFitWidth = true
        thirdLabel.textAlignment = .center
        
        self.contentView.addSubview(firstLabel)
        self.contentView.addSubview(secondLabel)
        self.contentView.addSubview(thirdLabel)
    }
    
    func setData(_ first: String, _ second: String, _ third: String) {
        self.firstLabel.text = first
        self.secondLabel.text = second
        self.thirdLabel.text = third
    }
}
