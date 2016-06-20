//
//  MapViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/6/17.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var Picker: UIPickerView!
    
    // for map
    let locationManager = CLLocationManager()
    var myPath = GMSMutablePath()
    var myTotalPath = [GMSMutablePath]()
    var startToRecordMyPath = false
    
    // for Picker
    let pickerData = ["Ubike Station", "Toilet"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setMap()
        setPickerView()
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
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
//            //set camera moves
//            if let lastLocation = locations.last {
//                
//                let currentLocation = CLLocationCoordinate2DMake(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude)
//                let vancouverCam = GMSCameraUpdate.setTarget(currentLocation)
//                mapView.moveCamera(vancouverCam)
//                
//            }
            
        }
        
    }
    
    func setPickerView(){
        Picker.dataSource = self
        Picker.delegate = self
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //myLabel.text = pickerData[row]
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        locationManager.stopUpdatingLocation()
//        
//    }
    
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

