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

    @IBOutlet weak var detailShowcaseImg: UIImageView!
    @IBOutlet weak var detailShowcaseTextField: UITextView!
    @IBOutlet weak var detailView: MaterialView!
    @IBOutlet weak var detailTextField: MaterialTextField!
    @IBOutlet weak var imgSelector: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: MaterialTextField!
    
    var post: Post!
    var request: Request?
    var descriptionRef: Firebase!
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    var comments = [Comment]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let post = post {
            detailShowcaseTextField.text = post.postDescription
            
            var detailImg: UIImage?
            
            if post.imageUrl != nil {
                if detailImg != nil {
                    self.detailShowcaseImg.image = detailImg
                    
                } else {
                    request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                        
                        if err == nil {
                            let img = UIImage(data: data!)!
                            self.detailShowcaseImg.image = img
                        }
                    })
                }
                
            } else {
                self.detailShowcaseImg.hidden = true
            }
        }
        
        DataService.ds.REF_COMMENTS.observeEventType(.Value, withBlock: { snapshot in
            self.comments = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    
                    print("THIS IS A COMMENT \(snap)")
                    
                    if let commentDict = snap.value as? Dictionary <String, AnyObject> {
                        let key = snap.key
                        let comment = Comment(commentKey: key, dict: commentDict)
                        
                        self.comments.insert(comment, atIndex: 0)
                    }
                }
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let comment = comments[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as? CommentCell {
            cell.configCell(comment)
            return cell
            
        } else {
            return CommentCell()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    @IBAction func editPostBtnPressed(sender: AnyObject) {
        editPostDescription()
    }
    
    func editPostDescription() {
        
        if let post = post {
            if let txt = detailTextField.text where txt != "" {
                post.editPost("description", txt: txt)
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
        
    }
}
