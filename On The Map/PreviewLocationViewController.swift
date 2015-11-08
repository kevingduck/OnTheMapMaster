//
//  PreviewLocationViewController.swift
//  On The Map
//
//  Created by Kevin Duck on 8/24/15.
//  Copyright (c) 2015 Kevin Duck. All rights reserved.
//

import MapKit
import UIKit

class PreviewLocationViewController : UIViewController,MKMapViewDelegate,UITextFieldDelegate{
    
    @IBOutlet weak var previewMap: MKMapView!
    @IBOutlet weak var urlField: UITextField!
    
    var latitude : Double!
    var longitude : Double!
    var mapString : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.previewMap.delegate = self
        self.urlField.delegate = self
    }
    
    @IBAction func dismiss(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func submitUrl(sender: UIButton) {
        var app = UIApplication.sharedApplication().delegate as! AppDelegate
        var studentDict = ["latitude": self.latitude, "longitude": self.longitude, "firstName": app.firstName, "lastName": app.lastName, "mediaURL": urlField.text]
        var studentInfo = StudentInformation(data: studentDict as! [String : AnyObject])
        ParseClient.sharedInstance().postStudent(studentInfo, mapString: self.mapString){(success,data) in
            if(success){
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else{
                Shared.showError(self,errorString: data["ErrorString"] as! String)
            }
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Setting up point
        var annotation = MKPointAnnotation()
        
        //Adding attributes to the pin
        annotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        annotation.title = "You are here: "
        self.previewMap.addAnnotation(annotation)
    }
    
    
    // Hide keyboard after touching elsewhere
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event!)
    }
    
    // Hide keyboard after return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}