//
//  DataService.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 25.01.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    private var _REF_COMMENTS = Firebase(url: "\(URL_BASE)/comments")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_COMMENTS: Firebase {
        return _REF_COMMENTS
    }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let currentUser = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        
        return currentUser!
    }
    
    func createFirebaseUser(uid: String, user: Dictionary <String, String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
}