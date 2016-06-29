//
//  StatisticsViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/26.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

protocol IndexDelegate: class {

    func giveIndex(cell: StatisticsViewController) -> Int

}

protocol DismissDelegation1: class {
    func showLabels()
}


class StatisticsViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    weak var delegate: IndexDelegate? //宣告法定代理人之權力
    weak var dismissDelegation1: DismissDelegation?
    
    // variables for CorData
    var fetchResultController: NSFetchedResultsController!
    var record: Record!
    var records: [Record] = []
    var locations: [Locations] = []
    var coreDataIsZero = true

    var index = 0
    
    // variables for view
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var distanceNum: UILabel!
    
    @IBOutlet weak var averageSpeed: UILabel!
    
    @IBOutlet weak var averageSpeedNum: UILabel!
    
    @IBOutlet weak var calories: UILabel!
    
    @IBOutlet weak var caloriesNum: UILabel!
    
    @IBOutlet weak var totalTime: UILabel!
    
    @IBOutlet weak var totalTimeNum: UILabel!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    // variables for controller
    
    var isPresented = true
    
    // for map
    let locationManager = CLLocationManager()
    var endPoint = CLLocation()
    var myPath = GMSMutablePath()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isPresented {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(close(_:)))
            
        }
        
        fetchCoreData()
        if records.count > 0 {
            getMyPath()
            coreDataIsZero = false
        }
        
        setView()
        setMap()
        
        // Do any additional setup after loading the view.
    }
    
    deinit {
        print("StatisticsViewController is dead")
    }
    
    @objc func close(sender: AnyObject?) {
         dismissDelegation1?.showLabels()
         dismissViewControllerAnimated(true, completion: nil)
         
        
    }
    
    override func viewDidLayoutSubviews() {
        setGradientBackground()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setView(){
        setLabel()
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
    func setLabel(){
        //print (records[records.count-1].averageSpeed)
        distance.text = "Distance"
        averageSpeed.text = "Average Speed"
        calories.text = "Calories"
        totalTime.text = "Total Time"
        distanceNum.text = "0 m"
        averageSpeedNum.text = "0 km / h"
        caloriesNum.text = "0 kcal"
        totalTimeNum.text = "00:00:00.00"
        
        if records.count > 0 {
            totalTimeNum.text =  records[records.count-1].timeDuration
            distanceNum.text = String(format:"%.2f m",(records[records.count-1].distance))
            averageSpeedNum.text = String(format:"%.2f km / h", records[records.count-1].averageSpeed)
            caloriesNum.text = String(format:"%.2f kcal",records[records.count-1].calories)
            totalTimeNum.text =  records[records.count-1].timeDuration
        }
    }
    
    func setGradientBackground(){
        gradientLayer.frame = self.view.bounds
        if isPresented {
            self.view.backgroundColor = UIColor(red: 99.0 / 255.0, green: 215.0 / 255.0, blue: 246.0 / 255.0, alpha: 0.5)
        } else {
            self.view.backgroundColor = UIColor(red: 99.0 / 255.0, green: 215.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
        }
        let color1 = UIColor(red: 0.0, green: 0, blue: 0, alpha: 0.6).CGColor
        let color2 = UIColor(red: 0.0, green: 0, blue: 0, alpha: 0.4).CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
        
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
}


extension StatisticsViewController {
 // FB Sharing
    @IBAction func shareButtonTapped(sender: AnyObject) {
        let sharedRecord = self.printScreen()
        FBSDKAccessToken.currentAccessToken()
        let loginManager = FBSDKLoginManager()
        
        loginManager.logInWithPublishPermissions(["publish_actions"], fromViewController: self, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if error != nil {
                NSLog(error.localizedFailureReason!)
                
            } else if result.isCancelled {
                NSLog("Canceled")
                
            } else if result.grantedPermissions.contains("publish_actions") {
                print(3)
                let photo = FBSDKSharePhoto()
                photo.image = self.printScreen()
                photo.userGenerated = true
                let content = FBSDKSharePhotoContent()
                content.photos = [photo]
                
                FBSDKShareAPI.shareWithContent(content, delegate: nil)
                FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)                
                
            } else {
                print ("unknown error in loggin Facebook")}
        })
       
        
    }
    
    func printScreen() ->  UIImage {
        //UIGraphicsBeginImageContextWithOptions(CGSizeMake(320,320), false, 0)
        UIGraphicsBeginImageContext(view.frame.size)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext();
        
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        //self.view?.drawViewHierarchyInRect(CGRectMake(-30, -30, self.frame.size.width, self.frame.size.height), afterScreenUpdates: true)
        let screenShot  = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    return screenShot
    }

}

// MARK: - CLLocationManagerDelegate

extension StatisticsViewController: CLLocationManagerDelegate {
    
    func setMap(){
        setMapDelegation()
    }
    
    func setMapDelegation(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            mapView.myLocationEnabled = false
            
            if coreDataIsZero == false {
                addPolyLine(myPath)
                
                let bounds = GMSCoordinateBounds(path: myPath)
                let insets = UIEdgeInsetsMake(35.3, 66.9, 21.8, 93.7)
                mapView.camera = mapView.cameraForBounds(bounds, insets: insets )!
            }
            
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            locationManager.stopUpdatingLocation()
        
    }
    
    func getMyPath(){
        let indexOfNewestRecord = records.count-1
        index = indexOfNewestRecord
        if isPresented == false && delegate?.giveIndex(self) != nil {
            
            index = (delegate?.giveIndex(self))!
            
        }
        
        let thisRoute = records[index].locations
        if thisRoute.count >= 2 {
            let thisRouteInArrayInNSArray = NSMutableArray(array: (thisRoute.allObjects as! [Locations]).sort{ $0.time!.compare($1.time!) == NSComparisonResult.OrderedAscending })
        
            for route in thisRouteInArrayInNSArray {
                myPath.addCoordinate(CLLocationCoordinate2DMake(route.latitude, route.longitude))
                endPoint = CLLocation(latitude: route.latitude, longitude: route.longitude)
            }
        } else if thisRoute.count > 0 {
            for route in thisRoute {
                myPath.addCoordinate(CLLocationCoordinate2DMake(route.latitude, route.longitude))
                endPoint = CLLocation(latitude: route.latitude, longitude: route.longitude)
            }
        } else {
            myPath.addCoordinate(CLLocationCoordinate2DMake(0.0, 0.0))
            endPoint = CLLocation(latitude: 0.0, longitude: 0.0)
        }
    }
    
    func addPolyLine(path: GMSMutablePath) {
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 10.0
        polyline.strokeColor = UIColor.mrBubblegumColor()
        polyline.geodesic = true
        polyline.map = mapView
    }
}


