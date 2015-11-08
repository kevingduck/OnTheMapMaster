//
//  MapViewController.swift
//  On The Map
//
//  Created by Kevin Duck on 8/24/15.
//  Copyright (c) 2015 Kevin Duck. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : UIViewController, UINavigationControllerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func navLogout(sender: AnyObject) {
        UdacityClient.logout(self)
    }
    
    @IBAction func showLocation(sender: UIBarButtonItem) {
        Shared.showLocationVC(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
      
        
        // Get fresh data
        ParseClient.sharedInstance().getStudents{ (success, data) in
            if(success){
                dispatch_async(dispatch_get_main_queue(), {
                     // saving the locations
                    ParseClient.sharedInstance().storeData(data["results"] as! [[String:AnyObject]])
                    // Clear old annotations
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.createPins(ParseClient.sharedInstance().students)
                  //}
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    let errorText = data["error"] as! String
                    //Show alert view
                    Shared.showError(self, errorString: errorText)
                })
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // If not logged in show login modal
        if (appDelegate.accountKey == ""){
            let loginController = self.storyboard!.instantiateViewControllerWithIdentifier("loginViewController") as! UIViewController
            self.presentViewController(loginController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPins(dataArray:[StudentInformation]){
        var annotations = [MKPointAnnotation]()
        
        for student in dataArray {
            //Creating singular pin
            var annotation = MKPointAnnotation()
            //Adding attributes to the pin
            annotation.coordinate = student.getCoordinate()
            annotation.title = student.getName()
            annotation.subtitle = student.getURL()
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            //Information circle ar the right of the annotation
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //Opening the url
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
    }
    
    
    
}