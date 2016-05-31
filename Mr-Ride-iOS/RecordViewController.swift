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
    // variables for view
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
    @IBOutlet weak var pauseButton: UIButton!
    
    // variables for model
    var startTime = NSTimeInterval()
    var timer = NSTimer()
    var pause = false
    
    @IBAction func CancelButtonTapped(sender: UIBarButtonItem) {

        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func FinishButtonTapped(sender: UIBarButtonItem) {
        timer.invalidate()
        let statisticsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StatisticsViewController") as? StatisticsViewController
        self.navigationController?.pushViewController(statisticsViewController!, animated: true)
    }
    
    @IBAction func startRecording(sender: UIButton) {
        pauseButton.hidden = false
        recordButton.hidden = true
        if !timer.valid {
            let aSelector : Selector = #selector(RecordViewController.updateTime)
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector,     userInfo: nil, repeats: true)
            if pause == false {
                
                startTime = NSDate.timeIntervalSinceReferenceDate()
            }
            else if pause == true {
                
            }
            
        }
    
    }

    @IBAction func pauseRecording(sender: UIButton) {
        pauseButton.hidden = true
        recordButton.hidden = false
        timer.invalidate()
        pause = true
        
    }
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

    func setMap(){
        let camera = GMSCameraPosition.cameraWithLatitude(25.048215, longitude: 121.517123, zoom: 17)
        mapView.myLocationEnabled = true
        mapView.camera = camera
        mapView.layer.cornerRadius = 10
        //mapView.settings.myLocationButton = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
        marker.title = "Taipei"
        marker.snippet = "Taiwan"
        marker.map = mapView
        
    }
//    class buttonPlayAndPause: UIButton {
//        override func drawRect(rect: CGRect) {
//            let path = UIBezierPath(ovalInRect: rect)
//            UIColor.redColor().setFill()
//            path.fill()
//        }
//    }

    
    //MARK: - Model Part
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        //need to check TimeStamp
        //NSTime for not checking the location so many times so that we can save space in core data
        // 三軸感應來算速度
    }
    
    
    
    // MARK: - View Part
    
    func setView(){
        setLabel()
        setButtons()
        pauseButton.hidden = true
        
    }
    
    func setLabel(){
        distance.text = "Distance"
        distanceNum.text = "109 m"
        averageSpeed.text = "Average Speed"
        averageSpeedNum.text = "12 km / h"
        calories.text = "Calories"
        caloriesNum.text = "910 kcal"
        time.text = "00:00:00.00"
        time.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
    }
    
    func setButtons(){
        recordButton.layer.cornerRadius = 30
        pauseButton.layer.cornerRadius = 4
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

    func updateTime(){
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        //calculate the hours in elapsed time.
        let hours = UInt8(elapsedTime / 360.0)
        
        elapsedTime -= (NSTimeInterval(hours) * 360)
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        time.text = "\(strHours):\(strMinutes):\(strSeconds).\(strFraction)"
        
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
