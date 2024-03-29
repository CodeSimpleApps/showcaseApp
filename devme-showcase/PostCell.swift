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
    @IBOutlet weak var deletePostBtn: MaterialButton!
    
    var post: Post!
    var request: Request?
    var likeRef: Firebase!
    var userPostRef: Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
        
        deletePostBtn.hidden = true
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        showcaseImg.clipsToBounds = true
    }

    func configCell(post: Post, img: UIImage?, profImg: UIImage?) {
        
        self.post = post
        
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        userPostRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("posts").childByAppendingPath(post.postKey)
        
        let userNameRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("username")
        
        userNameRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if post.userName != snapshot.value as? String {
                self.deletePostBtn.hidden = true
                
            } else if post.userName == snapshot.value as? String {
                self.deletePostBtn.hidden = false
            }
        })
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        self.userNameLbl.text = post.userName
        
        if post.imageUrl != nil {
            self.showcaseImg.hidden = false
            
            if img != nil {
                self.showcaseImg.image = img
            
            } else {
                request = Alamofire.request(.GET, post.imageUrl!).validate().response(completionHandler: { request, response, data, err in
                    
                    let img = UIImage(data: data!)
                    
                    guard img != nil else {
                        self.showcaseImg.image = UIImage(named: "camera")
                        return
                    }
                    
                    self.showcaseImg.image = img
                    FeedVC.imageCache.setObject(img!, forKey: self.post.imageUrl!)
                })
            }
        
        } else {
            self.showcaseImg.hidden = true
        }
        
        if post.userImgUrl != nil {
            if profImg != nil {
                self.profileImg.image = profImg
                
            } else {
                request = Alamofire.request(.GET, post.userImgUrl!).validate().response(completionHandler: { request, response, data, err in
                    
                    let imgP = UIImage(data: data!)
                    
                    guard imgP != nil else {
                        self.profileImg.image = UIImage(named: "camera")
                        return
                    }
                    
                    self.profileImg.image = imgP
                    FeedVC.imageCache.setObject(imgP!, forKey: self.post.userImgUrl!)
                })
            }
            
        } else {
            self.profileImg.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "heart-empty")
                
            } else {
                self.likeImg.image = UIImage(named: "heart-full")
            }
        })
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
    
    @IBAction func deletePost(sender: AnyObject) {
        self.post.deletePost()
        userPostRef.removeValue()
    }
}
