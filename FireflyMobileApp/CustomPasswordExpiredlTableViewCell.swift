//
//  CustomPersonalDetailTableViewCell.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 11/17/15.
//  Copyright © 2015 Me-tech. All rights reserved.
//

import UIKit

class CustomPasswordExpiredTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userlbl: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var password: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
