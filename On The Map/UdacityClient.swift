//
//  UdacityClient.swift
//  On The Map
//
//  Created by Kevin Duck on 8/24/15.
//  Copyright (c) 2015 Kevin Duck. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient: NSObject {
    
    var session : NSURLSession
    var userID : String
    
    override init() {
        session = NSURLSession.sharedSession()
        userID = ""
        super.init()
        
    }
    
    //Log into Udacity
    class func login(username: String, password: String, completionHandler: (success: Bool ,data: [String:AnyObject]) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, data: ["error": "\(error.localizedDescription)"])
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            var parsingError: NSError? = nil
            let jsonData = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! [String:AnyObject]
            let status = jsonData["status"] as? Int
            var success : Bool
            if status != nil {
                success = false
            }else {
                success = true
            }
            completionHandler(success: success, data: jsonData)
        }
        task.resume()
    }
    
    class func getPublicData(uniqueKey:String,completionHandler:(success:Bool, data:[String:AnyObject]) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(uniqueKey)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, data: ["ErrorString": error.localizedDescription])
            }else{
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                var parsingError: NSError? = nil
                let jsonData = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! [String:AnyObject]
                completionHandler(success: true,data: jsonData)
            }
        }
        task.resume()
    }
    
    class func logout(vc: UIViewController){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error ...
                Shared.showError(vc, errorString: error.localizedDescription)
            }
            else{
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                var parsingError: NSError? = nil
                let jsonData = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! [String:AnyObject]
                ParseClient.sharedInstance().students = []
                var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.accountKey = ""
                appDelegate.firstName = ""
                appDelegate.lastName = ""
                let loginController = vc.storyboard!.instantiateViewControllerWithIdentifier("loginViewController") as! UIViewController
                vc.presentViewController(loginController, animated: true, completion: nil)
            }
        }
        task.resume()
    }
    
    
    class func showSignUp(){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)

    }
}