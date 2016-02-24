//
//  DetailVC.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 24.02.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import UIKit
import Alamofire

class DetailVC: UIViewController {

    @IBOutlet weak var detailTextField: UITextView!
    @IBOutlet weak var detailShowcaseImg: UIImageView!
    
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let post = post {
            detailTextField.text = post.postDescription
        }
    }
}
