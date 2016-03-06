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
    @IBOutlet weak var loginBtn: MaterialButton!
    @IBOutlet weak var createUserBtn: MaterialButton!
    @IBOutlet weak var profileSettingsLbl: UILabel!
    @IBOutlet weak var profilePickLbl: UILabel!
    @IBOutlet weak var signupBtn: MaterialButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint2: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    var imagePicker: UIImagePickerController!
    
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
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
            self.bottomConstraint2.constant -= keyboardFrame.height
            self.topConstraint.constant -= keyboardFrame.height
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant -= keyboardFrame.height
            self.bottomConstraint2.constant += keyboardFrame.height
            self.topConstraint.constant += keyboardFrame.height
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        userImg.clipsToBounds = true
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil && DataService.ds.REF_USER_CURRENT.authData != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func fbBtnPressed(sender: UIButton) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed! Error \(facebookError)")
                
            } else {
                if let accessToken = FBSDKAccessToken.currentAccessToken().tokenString {
                
                    print("successfully logged in with facebook. \(accessToken)")
                    
                    DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                            
                        } else {
                            print("Logged in! \(authData)")
                            
                            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: accessToken, version: nil, HTTPMethod: "GET")
                            req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
                                if error == nil {
                                    print("result \(result)")
                                    
                                    let name = result["name"] as? String
                                    
                                    let user = ["provider": authData.provider!, "username": name!]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    
                                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                    
                                } else {
                                    print("error \(error)")
                                }
                            })
                        }
                    })
                    
                } else {
                    print("some err")
                }
            }
        }
    }
    
    @IBAction func createUserBtnPressed(sender: AnyObject) {
        loginBtn.hidden = true
        createUserBtn.hidden = true
        profilePickLbl.hidden = false
        profileSettingsLbl.hidden = false
        nickNameField.hidden = false
        userImg.hidden = false
        signupBtn.hidden = false
    }
    
    @IBAction func attemptLogin(sender: UIButton) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                if error != nil {
                    print(error.debugDescription)
                    self.showErrorAlert("Oops!", msg: "Can't do this!")
                    
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "uid")
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            self.showErrorAlert("Oops!", msg: "Forgot email or password?")
        }
    }
    
    @IBAction func attemptSignUp(sender: AnyObject) {
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "", let nick = nickNameField.text where nick != "", let profImg = userImg.image where imageSelected == true {
            
            DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                if error != nil {
                    self.showErrorAlert("Oops!", msg: "Can't do this!")
                    
                } else {
                    
                    var userImgUrl: String!
                    
                    DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { err, authData in
                        if err != nil {
                            print(err)
                            
                        } else {
                            
                            let urlStr = "https://post.imageshack.us/upload_api.php"
                            let url = NSURL(string: urlStr)!
                            let imgData = UIImageJPEGRepresentation(profImg, 0.2)!
                            let keyData = "PBFWVIAZ277b6635215df5b854e4cee43b000930".dataUsingEncoding(NSUTF8StringEncoding)!
                            let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                            
                            Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                                
                                multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "userimage", mimeType: "image/jpg")
                                multipartFormData.appendBodyPart(data: keyData, name: "key")
                                multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                                
                                }) { encodingResult in
                                    
                                switch encodingResult {
                                    
                                case .Success(let upload, _, _):
                                    upload.responseJSON(completionHandler: { response in
                                        if let info = response.result.value as? Dictionary <String, AnyObject> {
                                            if let links = info["links"] as? Dictionary <String, AnyObject> {
                                                if let imgLink = links["image_link"] as? String {
                                                    print("PROF IMG LINK: \(imgLink)")
                                                    
                                                    userImgUrl = imgLink
                                                    
                                                    var user: Dictionary <String, String>
                                                    
                                                    if userImgUrl != nil {
                                                        user = ["provider": authData.provider!, "username": nick, "userimage": userImgUrl]
                                                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                                                        
                                                        NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                                        
                                                        self.emailField.text = ""
                                                        self.passwordField.text = ""
                                                        self.nickNameField.text = ""
                                                        
                                                        self.loginBtn.hidden = false
                                                        self.createUserBtn.hidden = false
                                                        self.profilePickLbl.hidden = true
                                                        self.profileSettingsLbl.hidden = true
                                                        self.nickNameField.hidden = true
                                                        self.userImg.hidden = true
                                                        self.signupBtn.hidden = true
                                                    }
                                                }
                                            }
                                        }
                                    })
                                    
                                case .Failure(let error):
                                    print(error)
                                }
                            }
                        }
                    })
                }
            })
            
        } else {
            self.showErrorAlert("Oops!", msg: "Can't do this!")
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

