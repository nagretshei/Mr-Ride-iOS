//
//  MenuTableViewCell.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/24.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuItemLebel: UILabel!
    
    @IBOutlet weak var dot: UIView!
    

   
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


        if selected {
            menuItemLebel.textColor = UIColor.whiteColor()
            self.dot.hidden = false
        } else {
            menuItemLebel.textColor = UIColor(red: 255.0 / 225.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.5)
            self.dot.hidden = true
            self.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
    }

}
