//
//  Users.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 17.02.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import Foundation
import Firebase

class Users {
    
//    private var _userName: String!
    private var _userImageUrl: String?
    
    var userImageUrl: String? {
        return _userImageUrl
    }
    
    init(userImageUrl: String) {
        self._userImageUrl = userImageUrl
    }
}
