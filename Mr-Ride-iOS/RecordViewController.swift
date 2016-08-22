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
import AVFoundation
import Crashlytics

//AIzaSyD3hvVjvlfLIxu_md8QKlwJXpT7qf3o4Kc

class Record: NSManagedObject {

    @NSManaged var averageSpeed: Double
    @NSManaged var calories: Double
    @NSManaged var date: NSDate?
    @NSManaged var distance: Double
    @NSManaged var height: Double
    @NSManaged var weight: Double
    @NSManaged var id: String?
    @NSManaged var timeDuration: String?
    @NSManaged var locations: NSSet
    @NSManaged var month: String?

}

class TotalValue: NSManagedObject  {
    @NSManaged var totalDistanceInHistory: Double
    @NSManaged var totalAverageSpeed: Double
    @NSManaged var date: NSDate
}


class Locations: NSManagedObject {
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var time: NSDate?
    @NSManaged var record: Record?
    
}

protocol DismissDelegation: class {
    func showLabels()
}

class RecordViewController: UIViewController {
    
    
    
    weak var dismissDelegation: DismissDelegation?

    // variables for CorData
    let dataCalCulatingModel = DataCalCulatingModel()
    var record: Record!
    var recordWithValue = false
    

    var fetchResultController: NSFetchedResultsController!
    var records: [Record] = []
    var totalValue: TotalValue!
    var totalValues: [TotalValue] = []
    
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
    private var speed: CLLocationSpeed = abs(CLLocationSpeed())
    
    
    // for calculating carolies
    let userDefault = NSUserDefaults.standardUserDefaults()
    let height = 0.0 //userDefault.doubleForKey("userHeight")
    let weight = 0.0 //userDefault.doubleForKey("userHeight")
    var totalCal = 0.0
    var averageSpeedNumber = 0.0
    
    // for music
    var backgroundMusicPlayer =  AVAudioPlayer()
    var resumeTime = Double()
    var lastStopTime = Double()
    var playing = false
    
    
    @IBAction func CancelButtonTapped(sender: UIBarButtonItem) {
        dismissDelegation?.showLabels()
        dismissViewControllerAnimated(true, completion: nil)
        
        if playing == true {
            backgroundMusicPlayer.stop()
        }
    }
    
    @IBAction func FinishButtonTapped(sender: UIBarButtonItem) {
        timer.invalidate()
        startToRecordMyPath = false
        savingDataForMultiplePaths()
        myEntirePathInCoordinate.append(myPathInCoordinate)
        myPath.removeAllCoordinates()
        myPathInCoordinate = [CLLocation]()
        calculateAverageSpeed()
        if recordWithValue == true {
            saveCoreData()
            calculateTotalValuesForCoreData()
        }
        
        if playing == true {
            backgroundMusicPlayer.stop()
            backgroundMusicPlayer.stop()
        }
        
        let statisticsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StatisticsViewController") as? StatisticsViewController

        statisticsViewController?.dismissDelegation1 = self.dismissDelegation
        self.navigationController?.pushViewController(statisticsViewController!, animated: true)
        
    }
    
    @IBAction func startRecording(sender: UIButton) {
        recordWithValue = true
        pauseButton.hidden = false
        recordButton.hidden = true
        startToRecordMyPath = true
        distanceOfAPath = 0.0
        
        
        // play music
        let dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(dispatchQueue, {
            
            let bgMusicURL: NSURL = NSBundle.mainBundle().URLForResource("cloudyAndRainy", withExtension: "m4a")!
            
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(AVAudioSessionCategoryPlayback)
                try session.setActive(true)
                try self.backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: bgMusicURL)
                self.playing = true
            } catch {
                print("cannot fetch music")
            }
            self.backgroundMusicPlayer.numberOfLoops = 2
            self.backgroundMusicPlayer.prepareToPlay()
            self.backgroundMusicPlayer.currentTime = self.resumeTime
            self.backgroundMusicPlayer.play()
        })
        
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
        resumeTime = backgroundMusicPlayer.currentTime
        backgroundMusicPlayer.pause()
        
        
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let height = userDefault.doubleForKey("userHeight")
        let weight = userDefault.doubleForKey("userHeight")
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
    
    deinit {
        print("RecordViewController is dead")
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
        gradientLayer.frame = self.view.bounds
        self.view.backgroundColor = UIColor(red: 99.0 / 255.0, green: 215.0 / 255.0, blue: 246.0 / 255.0, alpha: 0.5)
        let color1 = UIColor(red: 0.0, green: 0, blue: 0, alpha: 0.6).CGColor
        let color2 = UIColor(red: 0.0, green: 0, blue: 0, alpha: 0.4).CGColor
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
    func calculateAverageSpeed(){
        if totalTime > 0 {
            averageSpeedNumber = (totalDistance / 1000 ) / (totalTime / 3600)
        } else {
            averageSpeedNumber = 0.0
        }
    }
    
    func calculateCarolies(){
        let kCalBurned = dataCalCulatingModel.kiloCalorieBurned(.Bike, speed: speed, weight: weight, time: elapsedTime / 3600)
        totalCal += kCalBurned
        caloriesNum.text = String(format:"%.2f kcal",totalCal)
    }

}


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
                    
                    myPathInCoordinate.append(myCurrentCoordinate)
                    distanceOfAPath = dataCalCulatingModel.calculatePolylineDistance(myPathInCoordinate)

                    totalDistance = previousRouteDistance + distanceOfAPath
                    distanceNum.text = "\(Int(round(totalDistance))) m"
                    
                    // get average speed
                    speed = abs(locationManager.location!.speed)
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

extension RecordViewController: NSFetchedResultsControllerDelegate {
    func saveCoreData(){
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            record = NSEntityDescription.insertNewObjectForEntityForName("Record", inManagedObjectContext: managedObjectContext) as! Record
            
            record.id = "1"
            record.averageSpeed = averageSpeedNumber
            record.calories = totalCal
            record.distance = totalDistance
            record.weight = weight
            record.height = height
            record.timeDuration = timeDurationInString
            
            let date = NSDate()
            let DateFormatter = NSDateFormatter()
            DateFormatter.dateFormat = "MMMM, yyyy"
            let monthStamp = DateFormatter.stringFromDate(date)
            
            record.date = date
            record.month = monthStamp
            
        
            // save locations
            var path = [Locations]()
            
            for route in myEntirePathInCoordinate {
                for location in route {
                    let locations =  NSEntityDescription.insertNewObjectForEntityForName("Locations", inManagedObjectContext: managedObjectContext) as! Locations
                    locations.time = NSDate()
                    locations.latitude = location.coordinate.latitude
                    locations.longitude = location.coordinate.longitude
                    path.append(locations)
                    
                }
                
            }
            record.locations =  NSSet(array: path)
            
            
            do{
                try managedObjectContext.save()
                
            } catch {
                print(error)
                return
            }
            
        }
    }
    
    
    func fetchCoreData(){
        let fetchRequest = NSFetchRequest(entityName: "Record")
        let sortData = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortData]
        
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            //print("will fetch")
            
            do {
                //performBlockAndWait
                try fetchResultController.performFetch()
                records = fetchResultController.fetchedObjects as! [Record]
                
            } catch {
                print(error)
            }
        }
    }
    func fetchCoreDataForTotalValue(){
        let fetchRequest = NSFetchRequest(entityName: "TotalValue")
        let sortData = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortData]
        
        
        if let managedObjectContext1 = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext1, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            //print("will fetch")
            
            do {
                try fetchResultController.performFetch()
                totalValues = fetchResultController.fetchedObjects as! [TotalValue]
                
            } catch {
                print(error)
            }
        }
    }
    func calculateTotalValuesForCoreData(){
        fetchCoreData()
        fetchCoreDataForTotalValue()
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            totalValue = NSEntityDescription.insertNewObjectForEntityForName("TotalValue", inManagedObjectContext: managedObjectContext) as! TotalValue
            
            let count = Double(records.count)
            if records.count == 1 {
                totalValue.totalAverageSpeed = averageSpeedNumber
                totalValue.totalDistanceInHistory = totalDistance
                totalValue.date = NSDate()
                print(totalValue.totalAverageSpeed)
                print(totalValue.totalDistanceInHistory)
            
            } else if records.count > 1 {
                totalValue.totalAverageSpeed = (((totalValues[totalValues.count-1].totalAverageSpeed * Double(totalValues.count-1)) + averageSpeedNumber)) / count
                
                totalValue.totalDistanceInHistory = totalValues[totalValues.count-1].totalDistanceInHistory + totalDistance
                    totalValue.date = NSDate()
                print(totalValue.totalAverageSpeed)
                print(totalValue.totalDistanceInHistory)
            }
        
            
            do{
                try managedObjectContext.save()
                
                
            } catch {
                print(error)
                return
            }
        }
        
    }
}



