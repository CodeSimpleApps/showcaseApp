//
//  EditVC.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 26.02.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import UIKit

class EditVC: UIViewController {
    
    @IBOutlet weak var editTextField: MaterialTextField!
    
    var post: Post!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let post = post {
            
        }
    }
    
    @IBAction func editPostBtnPressed(sender: AnyObject) {
        
//        let editedPost = self.post
//            if let txt = editTextField.text where txt != "" {
//                if let postDescriptionRef = DataService.ds.REF_POSTS.childByAppendingPath(editedPost.postKey).childByAppendingPath("description") {
//                postDescriptionRef.setValue(txt)
//            }
//        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
