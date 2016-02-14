//
//  ViewController.swift
//  devme-showcase
//
//  Created by Aleksey Kharitonov on 23.01.16.
//  Copyright © 2016 Aleksey Kharitonov. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var emailField: MaterialTextField!
    @IBOutlet weak var passwordField: MaterialTextField!
    @IBOutlet weak var nickNameField: MaterialTextField!
    @IBOutlet weak var userImg: UIImageView!

    var imagePicker: UIImagePickerController!
    
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil && DataService.ds.REF_USER_CURRENT.authData != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func fbBtnPressed(sender: UIButton) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed! Error \(facebookError)")
                
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("successfully logged in with facebook. \(accessToken)")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    if error != nil {
                        print("Login failed. \(error)")
                        
                    } else {
                        print("Logged in! \(authData)")
                        
                        let user = ["provider": authData.provider!, "username": "name"]
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func attemptLogin(sender: UIButton) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "", let nick = nickNameField.text where nick != "" { // ADD ", let img = userImg.image where imageSelected == true" TO THE END TO MAKE IMAGE REQUIRED
            
//            var userImageUrl: String!

            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                if error != nil {
                    print(error.code)
                    
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                        
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            if error != nil {
                                self.showErrorAlert("Couldn't crate account!", msg: "Problem creating account. Try something else!")
                                
                            } else {
                                
//                                    let urlStr = "https://post.imageshack.us/upload_api.php"
//                                    let url = NSURL(string: urlStr)!
//                                    let imgData = UIImageJPEGRepresentation(img, 0.2)!
//                                    let keyData = "PBFWVIAZ277b6635215df5b854e4cee43b000930".dataUsingEncoding(NSUTF8StringEncoding)!
//                                    let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
//                                    
//                                    Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
//                                        
//                                        multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
//                                        multipartFormData.appendBodyPart(data: keyData, name: "key")
//                                        multipartFormData.appendBodyPart(data: keyJSON, name: "format")
//                                        
//                                        }) { encodingResult in
//                                            
//                                            switch encodingResult {
//                                                
//                                            case .Success(let upload, _, _):
//                                                upload.responseJSON(completionHandler: { response in
//                                                    if let info = response.result.value as? Dictionary <String, AnyObject> {
//                                                        if let links = info["links"] as? Dictionary <String, AnyObject> {
//                                                            if let imgLink = links["image_link"] as? String {
//                                                                print("LINK: \(imgLink)")
//                                                                
//                                                                print(imgLink)
////                                                                userImageUrl = imgLink
//                                                            }
//                                                        }
//                                                    }
//                                                })
//                                                
//                                            case .Failure(let error):
//                                                print(error)
//                                            }
//                                            
//                                    }
                                
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { err, authData in
                                    
                                    if err != nil {
                                        self.showErrorAlert("Couldn't crate account!", msg: "Problem creating account. Try something else!")
                                    
                                    } else {
                                        
                                        //ADD USERIMAGE DICTIONARY WHEN PROBLEM WITH NIL WILL BE SLOVED!!!
                                        
                                        let user = ["provider": authData.provider!, "username": nick]
                                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    }
                                })
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                        })
                        
                    } else {
                        self.showErrorAlert("Could not login", msg: "Please check your username or password!")
                    }
                }
            })
            
        } else {
            showErrorAlert("Email, Password and Nickname required", msg: "You must enter an email, password and Nickname")
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        userImg.image = image
        imageSelected = true
    }
}
