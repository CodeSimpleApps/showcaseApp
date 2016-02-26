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

    @IBOutlet weak var detailShowcaseImg: UIImageView!
    @IBOutlet weak var detailShowcaseTextField: UITextView!
    @IBOutlet weak var detailView: MaterialView!
    
    var post: Post!
    var request: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
}
