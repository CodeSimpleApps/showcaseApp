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
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configCell(comment: Comment, currentPostKey: String, currentUserName: String) {
        
        self.comment = comment
        
        userNameLbl.text = comment.commentUserName
        commentTextView.text = comment.commentText
        
        if comment.commentUserName != currentUserName {
            self.deleteCommentBtn.hidden = true
            
        } else if comment.commentUserName == currentUserName {
            self.deleteCommentBtn.hidden = false
        }
    }
    
    @IBAction func deleteComment() {
        self.comment.deleteComment()
    }
}
