//
//  Comment.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 27.02.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    
    private var _commentUserName: String!
    private var _commentText: String!
    private var _commentKey: String!
    private var _commentRef: Firebase!
    
    var commentUserName: String {
        return _commentUserName
    }
    
    var commentText: String {
        return _commentText
    }
    
    var commentKey: String {
        return _commentKey
    }
    
    var commentRef: Firebase {
        return _commentRef
    }
    
    init(user: String, comment: String) {
        self._commentUserName = user
        self._commentText = comment
    }
    
    init(commentKey: String, dict: Dictionary <String, AnyObject>) {
        self._commentKey = commentKey
        
        if let userName = dict["username"] as? String {
            self._commentUserName = userName
        }
        
        if let text = dict["text"] as? String {
            self._commentText = text
        }
        
        self._commentRef = DataService.ds.REF_COMMENTS.childByAppendingPath(self._commentKey)
    }
    
    func deleteComment() {
        _commentRef.removeValue()
    }
}