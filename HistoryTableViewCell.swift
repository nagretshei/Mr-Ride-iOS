//
//  HistoryTableViewCell.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/26.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var timeDuration: UILabel!
    
    
    @IBOutlet weak var th: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

        // Configure the view for the selected state
    }

}
