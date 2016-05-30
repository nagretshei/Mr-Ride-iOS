//
//  RecordViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/25.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import GoogleMaps
//AIzaSyD3hvVjvlfLIxu_md8QKlwJXpT7qf3o4Kc

class RecordViewController: UIViewController  {
    
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var distanceNum: UILabel!
    @IBOutlet weak var averageSpeed: UILabel!
    @IBOutlet weak var averageSpeedNum: UILabel!
    @IBOutlet weak var calories: UILabel!
    @IBOutlet weak var caloriesNum: UILabel!
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    
   
    
    @IBOutlet weak var mapView: GMSMapView!
    
  

    
    // Set for Current Location
  
    
    
    // variables for map view part
    var locLat : Double = 10.0
    var locLng : Double = 25.0
    
    
    // current location
    var cllat =  Double ()
    var cllng = Double ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setMap()


    }
    
    override func viewDidLayoutSubviews() {
        setGradientBackground()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CancelButtonTapped(sender: UIBarButtonItem) {

        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func FinishButtonTapped(sender: UIBarButtonItem) {
        let statisticsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StatisticsViewController") as? StatisticsViewController
        self.navigationController?.pushViewController(statisticsViewController!, animated: true)
    }
    
    func setGradientBackground(){
        self.view.backgroundColor = UIColor.mrLightblueColor()
        gradientLayer.frame = self.view.bounds
        
        let color1 = UIColor(red: 0.0, green: 0, blue: 0, alpha: 0.6).CGColor as CGColorRef
        let color2 = UIColor(red: 0.0, green: 0, blue: 0, alpha: 0.4).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
      
    }
    
    func setView(){
        setLabel()
    }
    
    func setLabel(){
        distance.text = "distance"
        distanceNum.text = "109 m"
        averageSpeed.text = "Average Speed"
        averageSpeedNum.text = "12 km / h"
        calories.text = "Calories"
        caloriesNum.text = "910 kcal"
        time.text = "01:10:23.00"
        
    }
    
    func setMap(){
        let camera = GMSCameraPosition.cameraWithLatitude(-33.86, longitude: 151.20, zoom: 6)
        mapView.myLocationEnabled = true
        mapView.camera = camera
        //mapView.settings.myLocationButton = true
        
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
