//
//  UserModel.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/6/27.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import Foundation

class UserModel {
    let identifier: String
    var name: String
    var email: String?
    var profileImageURL: NSURL?
    var facebookURL: NSURL?
    
    init(identifier: String, name: String) {
        self.identifier = identifier
        self.name = name
    }
}
