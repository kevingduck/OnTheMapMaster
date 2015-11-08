//
//  LocationViewController.swift
//  On The Map
//
//  Created by Kevin Duck on 8/24/15.
//  Copyright (c) 2015 Kevin Duck. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LocationViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var locationLabel: UITextField!
  
    let indicator:UIActivityIndicatorView = UIActivityIndicatorView (activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
    var origin : UIViewController!
    
    @IBAction func cancelButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
  
    @IBAction func submitButton(sender: UIButton) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      // Activity indicator shown
      self.view.addSubview(indicator)
      print("added indicator view")
      indicator.bringSubviewToFront(self.view)
      indicator.startAnimating()
      
      print("Activity indicator on")
        CLGeocoder().geocodeAddressString(locationLabel.text, completionHandler: { (placemarks, error)->Void in
            // Activity indicator turned off
            print("Activity indicator now OFF")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error == nil {
                let place = placemarks[0] as! CLPlacemark
                let coordinate = place.location.coordinate
                Shared.showPreviewLocationVC(self.origin,vc: self, data: ["latitude": coordinate.latitude, "longitude": coordinate.longitude, "mapString": "\(place.locality), \(place.administrativeArea)"])
            }else{
                Shared.showError(self, errorString: error.localizedDescription)
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationLabel.delegate = self
      
        indicator.color = UIColor.magentaColor()
        indicator.frame = CGRectMake(0.0, 0.0, 100.0, 100.0)
        indicator.center = self.view.center

    }
    
    // Getting rid of keyboard after hitting return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Getting rid of keyboard after touching outside inputs
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event!)
    }
}
