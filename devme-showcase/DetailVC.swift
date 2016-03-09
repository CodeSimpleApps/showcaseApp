//
//  DetailVC.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 24.02.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class DetailVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var detailShowcaseTextView: UITextView!
    @IBOutlet weak var detailView: MaterialView!
    @IBOutlet weak var detailTextField: MaterialTextField!
    @IBOutlet weak var imgSelector: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: MaterialTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editFieldView: MaterialView!
    @IBOutlet weak var editBtn: MaterialButton!
    
    var post: Post!
    var request: Request?
    var commentRef: Firebase!
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var comments = [Comment]()
    var currentUser = ""
    var currentPostKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        if let post = post {
            detailShowcaseTextView.text = post.postDescription
            currentPostKey = post.postKey
            
            print("CURRENT POST KEY IS \(currentPostKey)")
            
            DataService.ds.REF_COMMENTS.childByAppendingPath(currentPostKey).observeEventType(.Value, withBlock: { snapshot in
                
                print("THIS IS SNAPSHOT FOR COMMENTS IN POST \(snapshot.value)")
                
                self.comments = []
                
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    
                    for snap in snapshots {
                        if let commentDict = snap.value as? Dictionary <String, AnyObject> {
                            let key = snap.key
                            let specificComment = Comment(currentPostKey: self.currentPostKey, commentKey: key, dict: commentDict)
                            
                            self.comments.insert(specificComment, atIndex: 0)
                        }
                        self.tableView.reloadData()
                    }
                }
            })
            
            if DataService.ds.REF_USER_CURRENT.authData != nil {
                
                DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: { snapshot in
                    let currentUser = snapshot.value.objectForKey("username") as? String
                    
                    print("CURRENT USER IN DETAIL VC: \(currentUser)")
                    self.currentUser = currentUser!
                    
                    if currentUser != post.userName {
                        self.detailTextField.enabled = false
                        self.imgSelector.hidden = true
                        self.editBtn.enabled = false
                        self.editBtn.backgroundColor = UIColor.lightGrayColor()
                        
                    } else if currentUser == post.userName {
                        self.detailTextField.enabled = true
                        self.imgSelector.hidden = false
                        self.editBtn.enabled = true
                    }
                })
                
            } else {
                currentUser = "EMPTY"
            }
            
            DataService.ds.REF_COMMENTS.observeEventType(.ChildRemoved, withBlock: { snapshot in
                if let key = snapshot.key {
                    DataService.ds.REF_POSTS.childByAppendingPath(self.currentPostKey).childByAppendingPath("comments").childByAppendingPath(key).removeValue()
                }
                self.tableView.reloadData()
            })
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant += keyboardFrame.height
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant -= keyboardFrame.height
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let comment = comments[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as? CommentCell {
            
            cell.configCell(comment, currentPostKey: self.currentPostKey, currentUserName: self.currentUser)
            return cell
            
        } else {
            return CommentCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    @IBAction func editPostBtnPressed(sender: AnyObject) {
        
        if let post = post {
            if let txt = detailTextField.text where txt != "" {
                post.editPost("description", txt: txt)
                detailShowcaseTextView.text = txt
                detailTextField.text = ""
            }
            
            if let img = imgSelector.image where imageSelected == true {
                
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "PBFWVIAZ277b6635215df5b854e4cee43b000930".dataUsingEncoding(NSUTF8StringEncoding)!
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
                                        print("LINK: \(imgLink)")
                                        
                                        post.editPost("imageUrl", txt: imgLink)
                                    }
                                }
                            }
                        })
                        
                    case .Failure(let error):
                        print(error)
                    }
                }
            }
        }
        detailTextField.resignFirstResponder()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imgSelector.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makeComment(sender: AnyObject) {
        
        if let txt = commentTextField.text where txt != "" {
            
            let comment: Dictionary <String, AnyObject> = [
                "username": currentUser,
                "text": commentTextField.text!
            ]
            
            let firebaseComment = DataService.ds.REF_COMMENTS.childByAppendingPath(currentPostKey).childByAutoId()
            firebaseComment.setValue(comment)
            
            commentTextField.text = ""
            tableView.reloadData()
        }
        commentTextField.resignFirstResponder()
    }
}
