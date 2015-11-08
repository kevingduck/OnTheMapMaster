//
//  LoginViewController.swift
//  On The Map
//
//  Created by Kevin Duck on 8/24/15.
//  Copyright (c) 2015 Kevin Duck. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var session: NSURLSession!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = NSURLSession.sharedSession()
        self.usernameField.delegate = self
        self.passwordField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func sendButton(sender: UIButton) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        UdacityClient.login(usernameField.text!,password: passwordField.text!){ (success, jsonData) in
            if(success){
                self.finishLogin(jsonData)
            }else {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                let errorText = jsonData["error"] as! String
                Shared.showError(self, errorString: errorText)
            }
        }
    }
    
    // Show sign up 
    @IBAction func signUp(sender: UIButton) {
        UdacityClient.showSignUp()
    }
    
    // hide keyboard after touching somewhere else
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event!)
    }
    
    // hide keyboard after pressing return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Retrieve session ID
    func finishLogin(data : [String:AnyObject?]){
        dispatch_async(dispatch_get_main_queue(), {
            var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let account = data["account"] as! [String:AnyObject]
            let accountKey = account["key"] as! String
            appDelegate.accountKey = accountKey
            UdacityClient.getPublicData(accountKey, completionHandler: {(success,data) in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if(success){
                    let user = data["user"] as! [String:AnyObject]
                    appDelegate.firstName = user["first_name"] as! String
                    appDelegate.lastName = user["last_name"] as! String
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else{
                    Shared.showError(self, errorString: data["ErrorString"] as! String)
                }
            })
        })
    }
    

    
    
}