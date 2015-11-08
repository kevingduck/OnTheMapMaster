//
//  ListViewController.swift
//  On The Map
//
//  Created by Kevin Duck on 8/28/15.
//  Copyright (c) 2015 Kevin Duck. All rights reserved.
//

import UIKit

class ListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func showLocation(sender: UIBarButtonItem) {
        Shared.showLocationVC(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        ParseClient.sharedInstance().getStudents{ (success, data) in
            if(success){
                dispatch_async(dispatch_get_main_queue(), {
                    ParseClient.sharedInstance().storeData(data["results"] as! [[String:AnyObject]])
                    self.tableView.reloadData()
                })
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    let errorText = data["error"] as! String
                    Shared.showError(self, errorString: errorText)
                })
            }
        }
    }
    
    @IBAction func navLogout(sender: UIBarButtonItem) {
        UdacityClient.logout(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! UITableViewCell
        let student = ParseClient.sharedInstance().students[indexPath.row]
        
        cell.textLabel?.text = student.getName()
        cell.detailTextLabel?.text = student.getURL()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student =  ParseClient.sharedInstance().students[indexPath.row]
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: student.getURL())!)
    }
}