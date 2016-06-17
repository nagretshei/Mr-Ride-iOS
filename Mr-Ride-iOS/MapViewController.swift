//
//  MapViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/6/17.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    
    // for map
    let locationManager = CLLocationManager()
//    var endPoint = CLLocation()
//    var myPath = GMSMutablePath()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setMap()
    }


    @IBAction func MenuButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setView(){
//        setLabelAndButton()
        setNavigationBar()
        
    }

    func setNavigationBar(){
        //set navBar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mrLightblueColor()
        self.navigationController?.navigationBar.translucent = false
        // delete the shadow
        
        //self.navigationController!.navigationBar.backgroundColor = UIColor.mrLightblueColor()
        let shadowImg = UIImage()
        self.navigationController?.navigationBar.shadowImage = shadowImg
        self.navigationController?.navigationBar.setBackgroundImage(shadowImg, forBarMetrics: .Default)
        
    }

}

extension MapViewController: CLLocationManagerDelegate {
    
    func setMap(){
        setMapDelegation()
    }
    
    func setMapDelegation(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            print ("map")
            //mapView.myLocationEnabled = true
            
//            if coreDataIsZero == false {
//                addPolyLine(myPath)
//                
//                let bounds = GMSCoordinateBounds(path: myPath)
//                let insets = UIEdgeInsetsMake(35.3, 66.9, 21.8, 93.7)
//                mapView.camera = mapView.cameraForBounds(bounds, insets: insets )!
//            }
            
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
    }
    
//    func getMyPath(){
//        let indexOfNewestRecord = records.count-1
//        index = indexOfNewestRecord
//        if isPresented == false && delegate?.giveIndex(self) != nil {
//            
//            index = (delegate?.giveIndex(self))!
//            
//        }
//        
//        let thisRoute = records[index].locations
//        if thisRoute.count >= 2 {
//            let thisRouteInArrayInNSArray = NSMutableArray(array: (thisRoute.allObjects as! [Locations]).sort{ $0.time!.compare($1.time!) == NSComparisonResult.OrderedAscending })
//            
//            for route in thisRouteInArrayInNSArray {
//                myPath.addCoordinate(CLLocationCoordinate2DMake(route.latitude, route.longitude))
//                endPoint = CLLocation(latitude: route.latitude, longitude: route.longitude)
//            }
//        } else if thisRoute.count > 0 {
//            for route in thisRoute {
//                myPath.addCoordinate(CLLocationCoordinate2DMake(route.latitude, route.longitude))
//                endPoint = CLLocation(latitude: route.latitude, longitude: route.longitude)
//            }
//        } else {
//            myPath.addCoordinate(CLLocationCoordinate2DMake(0.0, 0.0))
//            endPoint = CLLocation(latitude: 0.0, longitude: 0.0)
//        }
//    }
//    
//    func addPolyLine(path: GMSMutablePath) {
//        let polyline = GMSPolyline(path: path)
//        polyline.strokeWidth = 10.0
//        polyline.strokeColor = UIColor.mrBubblegumColor()
//        polyline.geodesic = true
//        polyline.map = mapView
//    }
}

