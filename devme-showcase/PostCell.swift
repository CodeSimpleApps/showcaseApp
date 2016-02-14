//
//  PostCell.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 26.01.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    
    var post: Post!
    var users: Users!
    var request: Request?
    var likeRef: Firebase!
    var userPostRef: Firebase!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }
    
    func configCell(post: Post, img: UIImage?) {
        
        self.post = post
        
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        userPostRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("posts").childByAppendingPath(post.postKey)
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            if img != nil {
                self.showcaseImg.image = img
            
            } else {
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    
                    }
                })
            }
            
        } else {
            self.showcaseImg.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "heart-empty")
                
            } else {
                self.likeImg.image = UIImage(named: "heart-full")
            }
        })
        
        userPostRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            print("THIS IS SNAPSHOT VALUE IN CONFIGCELL: \(snapshot.value)")
            if let doesNotExist = snapshot.value as? NSNull {
                self.userNameLbl.text = "NULL"
                self.userPostRef.setValue(true)
            } else {
                self.userPostRef.setValue(true)
            }
        })
        
//        let userNameRef = DataService.ds.REF_USERS.childByAppendingPath("username")
//        userNameRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
//            print(snapshot.value)
//            if let userName = snapshot.value as? String {
//                self.userNameLbl.text = userName
//                print("THIS IS USERNAME \(userName)")
//            }
//        })

    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
                
            } else {
                self.likeImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }
}
