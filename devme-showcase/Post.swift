//
//  Post.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 29.01.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _userName: String!
    private var _postKey: String!
    private var _postRef: Firebase!
    private var _userRef: Firebase!
    
    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var userName: String {
        get {
            return _userName
        }
        
        set {
            _userName = newValue
        }
    }
    
    var postKey: String {
        return _postKey
    }
    
    var postRef: Firebase {
        return _postRef
    }
    
    var userRef: Firebase {
        return _userRef
    }
    
    init(description: String, imageUrl: String?, userName: String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._userName = userName
    }
    
    init(postKey: String, dictionary: Dictionary <String, AnyObject>) {
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        if let name = dictionary["username"] as? String {
            self._userName = name
        }
        
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.childByAppendingPath("likes").setValue(_likes)
    }
}