//
//  FeedVC.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 26.01.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    var imagePicker: UIImagePickerController!
    var posts = [Post]()
    var imageSelected = false
    var currentUserImgUrl = ""
    var currentUser = ""
    var userPostRef: Firebase!
    var post: Post!
    
    static var imageCache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 400
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let postDict = snap.value as? Dictionary <String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        
                        self.posts.insert(post, atIndex: 0)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
        
        if DataService.ds.REF_USER_CURRENT.authData != nil {
            
            DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: { snapshot in
                let currentUser = snapshot.value.objectForKey("username") as? String
                self.currentUser = currentUser!
            })
            
        } else {
            currentUser = "EMPTY"
        }
        
        DataService.ds.REF_USER_CURRENT.childByAppendingPath("userimage").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let userImgUrl = snapshot.value as? String {
                self.currentUserImgUrl = userImgUrl
            }
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
                
        guard let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell else {
            return PostCell()
        }
        
        cell.request?.cancel()
        
        var img: UIImage?
        var imgP: UIImage?
        
        if let url = post.imageUrl {
            img = FeedVC.imageCache.objectForKey(url) as? UIImage
        }
        
        if let profUrl = post.userImgUrl {
            imgP = FeedVC.imageCache.objectForKey(profUrl) as? UIImage
        }
        
        cell.configCell(post, img: img, profImg: imgP)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        guard post.imageUrl == nil else {
            return tableView.estimatedRowHeight
        }
        
        return 150
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let post = posts[indexPath.row]
        performSegueWithIdentifier("DetailVC", sender: post)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        if let txt = postField.text where txt != "" {
            
            if let img = imageSelectorImage.image where imageSelected == true {
                
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                    }) { encodingResult in
                    
                        switch encodingResult {
                            
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { response in
                                if let info = response.result.value as? Dictionary <String, AnyObject> {
                                    if let links = info["links"] as? Dictionary <String, AnyObject> {
                                        if let imgLink = links["image_link"] as? String {
                                            
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                            })
                            
                        case .Failure(let error):
                            print(error)
                        }
                    }
                
            } else {
                self.postToFirebase(nil)
            }
        }
        postField.resignFirstResponder()
    }
    
    func postToFirebase(imgUrl: String?) {
        
        var post: Dictionary <String, AnyObject> = [
            "description": postField.text!,
            "likes": 0,
            "username": currentUser,
            "userimage": currentUserImgUrl
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl!
        }
        
        DataService.ds.REF_POSTS.observeEventType(.ChildAdded, withBlock: { snapshot in
            if let key = snapshot.key {
                self.postToUser(key)
            }
        })

        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelectorImage.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
    
    func postToUser(postKey: String) {
        
        userPostRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("posts").childByAppendingPath(postKey)
        
        userPostRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                self.userPostRef.setValue(true)
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailVC" {
            if let destVC = segue.destinationViewController as? DetailVC {
                if let post = sender as? Post {
                    destVC.post = post
                }
            }
        }
    }
    
    @IBAction func logOutBtnPressed(sender: AnyObject) {
        DataService.ds.REF_USER_CURRENT.unauth()
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UID)

        self.dismissViewControllerAnimated(true, completion: nil)
    }
}