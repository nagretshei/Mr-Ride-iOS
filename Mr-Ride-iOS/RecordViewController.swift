//
//  RecordViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/25.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
//AIzaSyD3hvVjvlfLIxu_md8QKlwJXpT7qf3o4Kc

class Record: NSManagedObject {
    @NSManaged var averageSpeed: Double
    @NSManaged var calories: Double
    @NSManaged var count: Int32
    @NSManaged var date: NSDate
    @NSManaged var distance: Double
    @NSManaged var height: Double
    @NSManaged var weight: Double
    @NSManaged var id: String
    @NSManaged var timeDuration: String
    @NSManaged var locations: NSSet

}


class Locations: NSManagedObject {
        @NSManaged var latitude: Double
        @NSManaged var longitude: Double
        @NSManaged var record: Record?
    
}

class RecordViewController: UIViewController {
    
    let dataCalCulatingModel = DataCalCulatingModel()
    var record: Record!
//    var locations: Locations!

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
    
    //var startTime = NSTimeInterval()
    var timer = NSTimer()
    var startTime = NSTimeInterval()
    var currentTime = NSDate.timeIntervalSinceReferenceDate()
    var elapsedTime = NSTimeInterval()
    var pause = false
    var previousStopTime: NSTimeInterval = 0.0
    var totalStopTime: NSTimeInterval = 0.0
    var totalTime = NSTimeInterval()
    var timeDurationInString = ""
    
    // for map
    let locationManager = CLLocationManager()
    var myPath = GMSMutablePath()
    var myTotalPath = [GMSMutablePath]()
    var startToRecordMyPath = false
    
    private var previousRouteDistance = 0.0
    private var distanceOfAPath = 0.0
    var totalDistance = 0.0
    private var myCurrentCoordinate = CLLocation()
    private var myPathInCoordinate = [CLLocation]()
    private var myEntirePathInCoordinate = [[CLLocation]]()
    private var speed: CLLocationSpeed = CLLocationSpeed()
    
    
    // for calculating carolies
    var height = 175.3 //cm
    var weight = 65.6 //kg
    var totalCal = 0.0
    var averageSpeedNumber = 0.0
    
    
    @IBAction func CancelButtonTapped(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func FinishButtonTapped(sender: UIBarButtonItem) {
        timer.invalidate()
        startToRecordMyPath = false
        savingDataForMultiplePaths()
        myEntirePathInCoordinate.append(myPathInCoordinate)
        myPath.removeAllCoordinates()
        myPathInCoordinate = [CLLocation]()
        calculateAverageSpeed()
        saveCoreData()
        
        let statisticsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StatisticsViewController") as? StatisticsViewController
        self.navigationController?.pushViewController(statisticsViewController!, animated: true)
    }
    
    @IBAction func startRecording(sender: UIButton) {
        pauseButton.hidden = false
        recordButton.hidden = true
        startToRecordMyPath = true
        distanceOfAPath = 0.0
        
        if !timer.valid {
            
            if pause == false {
                startTime = NSDate.timeIntervalSinceReferenceDate()
            }
            else {
                
                let currentTime = NSDate.timeIntervalSinceReferenceDate()
                let stopTime = currentTime - previousStopTime
                
                totalStopTime += stopTime
                
            }
            
            let aSelector : Selector = #selector(RecordViewController.updateTime)
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector,     userInfo: nil, repeats: true)
            
        }
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        pauseButton.hidden = true
        recordButton.hidden = false
        previousStopTime = NSDate.timeIntervalSinceReferenceDate()
        timer.invalidate()
        calculateAverageSpeed()
        
        pause = true
        startToRecordMyPath = false
        savingDataForMultiplePaths()
        myEntirePathInCoordinate.append(myPathInCoordinate)
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
        averageSpeed.text = "Current Speed"
        averageSpeedNum.text = "0 km / h"
        calories.text = "Calories"
        caloriesNum.text = "0 kcal"
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
        
        //Find the difference between current time and start time.
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        
        elapsedTime = (currentTime - startTime) - totalStopTime
        totalTime = elapsedTime
        
        //calculate the minutes in elapsed time.
        
        let hours = Int(floor(elapsedTime / 3600.0))
        
        elapsedTime -= (NSTimeInterval(hours) * 3600)
        
        //calculate the minutes in elapsed time.
        
        let minutes = Int(floor(elapsedTime / 60.0))
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = Int(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        
        let fraction = Int(elapsedTime * 100)
        
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        time.text = "\(strHours):\(strMinutes):\(strSeconds).\(strFraction)"
        timeDurationInString = "\(strHours):\(strMinutes):\(strSeconds).\(strFraction)"
    }
    
    
    // Model
    
    func saveCoreData(){
        print ("******************")
        //print (myEntirePathInCoordinate)
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            record = NSEntityDescription.insertNewObjectForEntityForName("Record", inManagedObjectContext: managedObjectContext) as! Record
            record.count = 1
            record.id = "1"
            record.averageSpeed = averageSpeedNumber
            record.calories = totalCal
            record.distance = totalDistance
            record.weight = weight
            record.height = height
            record.timeDuration = timeDurationInString
            record.date = NSDate()
            
            // save locations
            
            var path = [Locations]()
            
            
            
            //print(myEntirePathInCoordinate[0])
            for location in myEntirePathInCoordinate[0] {
                var locations =  NSEntityDescription.insertNewObjectForEntityForName("Locations", inManagedObjectContext: managedObjectContext) as! Locations
                locations.latitude = location.coordinate.latitude
                locations.longitude = location.coordinate.longitude
                path.append(locations)
                
            }
            //print(path)
            record.locations =  NSSet(array: path)
            
            
            do{
                try managedObjectContext.save()
                
            } catch {
                print(error)
                return
            }
            
        }
    }
    
    
    
    func calculateAverageSpeed(){
        if totalTime > 0{
            averageSpeedNumber = (totalDistance / 1000 ) / (totalTime / 3600)
        } else {
            averageSpeedNumber = 0.0
        }
    }
    
    func calculateCarolies(){
        let kCalBurned = dataCalCulatingModel.kiloCalorieBurned(.Bike, speed: speed, weight: 70.0, time: elapsedTime / 3600)
        totalCal += kCalBurned
        caloriesNum.text = String(format:"%.2f kcal",totalCal)
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
            //mapView.settings.myLocationButton = true
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
                    //print (myCurrentCoordinate)
                    
                    myPathInCoordinate.append(myCurrentCoordinate)
                    distanceOfAPath = dataCalCulatingModel.calculatePolylineDistance(myPathInCoordinate)

                    totalDistance = previousRouteDistance + distanceOfAPath
                    distanceNum.text = "\(Int(round(totalDistance))) m"
                    
                    // get average speed
                    speed = locationManager.location!.speed
                    averageSpeedNum.text = "\(Int(round(speed * 1.609344 / 1000 * 3600))) km / h"
                    
                    //for drawing polyline
                    myPath.addCoordinate(CLLocationCoordinate2DMake(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude))
                    addPolyLine(myPath)
                    calculateCarolies()
                    
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
        
        // saving total distance
        previousRouteDistance += distanceOfAPath
        distanceOfAPath = 0.0
        
    }
    
}

