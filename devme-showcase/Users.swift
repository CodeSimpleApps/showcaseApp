//
//  Users.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 08.02.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import Foundation
import Firebase

class Users {
    
    private var _imageUrl: String?
    private var _userName: String!
    private var _userKey: String!
    private var _userRef: Firebase!
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var userName: String {
        return _userName
    }
    
    var userKey: String {
        return _userKey
    }
    
    var userRef: Firebase {
        return _userRef
    }
    
    init(userKey: String, dictionary: Dictionary <String, AnyObject>) {
        self._userKey = userKey
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let name = dictionary["username"] as? String {
            self._userName = name
        }
        
        self._userRef = DataService.ds.REF_USERS.childByAppendingPath(self._userKey)
    }
}