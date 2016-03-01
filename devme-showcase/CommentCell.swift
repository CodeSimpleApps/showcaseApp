//
//  CommentCell.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 27.02.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import UIKit
import Firebase

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var deleteCommentBtn: MaterialButton!
    
    var comment: Comment!
    var userNameRef: Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configCell(comment: Comment) {
        
        self.comment = comment
        
        userNameRef = DataService.ds.REF_COMMENTS.childByAppendingPath(comment.commentKey).childByAppendingPath("username")
        
        userNameRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if comment.commentUserName != snapshot.value as? String {
                self.deleteCommentBtn.hidden = true
                
            } else if comment.commentUserName == snapshot.value as? String {
                self.deleteCommentBtn.hidden = false
            }
        })
 
        userNameLbl.text = comment.commentUserName
        commentTextView.text = comment.commentText
    }
    
    @IBAction func deleteComment() {
        self.comment.deleteComment()
    }
}
