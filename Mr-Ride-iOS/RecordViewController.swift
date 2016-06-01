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

class RecordViewController: UIViewController {
    
    
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
    
    var startTime = NSTimeInterval()
    var timer = NSTimer()
    var pause = false
    // for map
    let locationManager = CLLocationManager()
   
    var myPath = GMSMutablePath()
    var myTotalPath = [GMSMutablePath]()
    var startToRecordMyPath = false
    
    var previousDistance = 0.0
    var distanceOfAPath = 0.0
    var totalDistance = 0.0
    var myCurrentCoordinate = CLLocation()
    var myPathInCoordinate = [CLLocation]()
    let dataCalCulatingModel = DataCalCulatingModel()
    
    @IBAction func CancelButtonTapped(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func FinishButtonTapped(sender: UIBarButtonItem) {
        timer.invalidate()
        startToRecordMyPath = false
        savingDataForMultiplePaths()
        myPath.removeAllCoordinates()
        myPathInCoordinate = [CLLocation]()
        
        let statisticsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StatisticsViewController") as? StatisticsViewController
        self.navigationController?.pushViewController(statisticsViewController!, animated: true)
    }
    
    @IBAction func startRecording(sender: UIButton) {
        pauseButton.hidden = false
        recordButton.hidden = true
        startToRecordMyPath = true
        distanceOfAPath = 0.0
        
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
        startToRecordMyPath = false
        savingDataForMultiplePaths()
        myPath.removeAllCoordinates()
        myPathInCoordinate = [CLLocation]()
        
        
        
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
    
    
    // MARK: - View Part
    
    func setView(){
        setLabel()
        setButtons()
        setNavigationBar()
        pauseButton.hidden = true
        
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
    
    func setLabel(){
        distance.text = "Distance"
        distanceNum.text = "0 m"
        averageSpeed.text = "Average Speed"
        averageSpeedNum.text = "0 km / h"
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
    

}





//func locationManager(manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
//    //need to check TimeStamp
//    //NSTime for not checking the location so many times so that we can save space in core data
//    // 三軸感應來算速度
//}

// MARK: - CLLocationManagerDelegate

extension RecordViewController: CLLocationManagerDelegate {
    
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
            
            //set camera moves
            if let lastLocation = locations.last {
                
                let currentLocation = CLLocationCoordinate2DMake(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude)
                let vancouverCam = GMSCameraUpdate.setTarget(currentLocation)
                mapView.moveCamera(vancouverCam)
                
                
                
                if startToRecordMyPath == true {
                    //updating variables for calculating distance
                    myCurrentCoordinate = lastLocation 
                    myPathInCoordinate.append(myCurrentCoordinate)
                    distanceOfAPath = dataCalCulatingModel.calculatePolylineDistance(myPathInCoordinate)
                    totalDistance = previousDistance + distanceOfAPath
                    distanceNum.text = "\(Int(round(totalDistance))) m"
                    
                    // get average speed
                    var speed: CLLocationSpeed = CLLocationSpeed()
                    speed = locationManager.location!.speed
                    averageSpeedNum.text = "\(Int(round(speed))) km / h"
                    
                    //for drawing polyline
                    myPath.addCoordinate(CLLocationCoordinate2DMake(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude))
                    addPolyLine(myPath)


                }
            }
        }
    }

    
    func addPolyLine(path: GMSMutablePath) {
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 10.0
        polyline.strokeColor = UIColor.mrBubblegumColor()
        polyline.geodesic = true
        polyline.map = mapView
    }
   
    
    func savingDataForMultiplePaths(){
        // saving multi polyline drawing
        myTotalPath.append(myPath)
        for p in myTotalPath {
            addPolyLine(p)
        }
        
        // saving total duration time
        
        // saving total distance
        previousDistance += distanceOfAPath
        totalDistance = previousDistance + distanceOfAPath
        
        
        
    }
    

//    func calculateCarolies(){
//        //.Bike is of enum Exercise
//        //speed's unit: km/hr
//        //timeSpent's unit: s
//        //weight unit: kg
//        //kCalBurned's unit: kcal
//        //kcalBurnedLabel is the UIkit to display
//        let calorieCalculator = CalorieCalculator()
//        let kCalBurned = calorieCalculator.kiloCalorieBurned(.Bike, speed: speed, weight: 70.0, time: spentTime/3600)
//        kcalBurnedLabel.text = String(format:"%.2f kcal",kCalBurned)
//    }
    
    
    
    // Model Part
    
//    func calculatePolylineDistance(path: [CLLocation]) -> Double {
//        var distance = 0.0
//        for spot in 0 ..< (path.count - 1) {
//            let sectionDistance = path[spot].distanceFromLocation(path[(spot + 1)])
//            distance += sectionDistance
//        }
//        
//        return distance
//    }
    
    

}

