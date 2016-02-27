//
//  CommentCell.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 27.02.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    var comment: Comment!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configCell(comment: Comment) {
        
        self.comment = comment
        
        userNameLbl.text = comment.commentUserName
        commentTextView.text = comment.commentText
    }
}
