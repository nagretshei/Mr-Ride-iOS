//
//  MapViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/6/17.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import CoreData

enum PickerViewCases {
    case Toilets
    case UbikeStations
}

class DowntownToilet: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var address: String?
    @NSManaged var kind: String?
    
}

class RiversideToilet: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var address: String?
    @NSManaged var kind: String?
    
}

class Stations: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var address: String?
    @NSManaged var dist: String?
    @NSManaged var bikeLeft: String?
    
}


class MapViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var pickView: UIPickerView!
    
    @IBOutlet weak var lookFor: UIButton!

    @IBOutlet weak var mapView: GMSMapView!
    

    
     var fetchResultController: NSFetchedResultsController!
    // set station data variables for CoreData
    var station: Stations!
    var stations: [Stations] = []
    
    // set toilet data variables for CoreData
    var downtownToilet: DowntownToilet!
    var downtownToilets: [DowntownToilet] = []
    
    // for map
    let locationManager = CLLocationManager()
    var myPath = GMSMutablePath()
    var myTotalPath = [GMSMutablePath]()
    var startToRecordMyPath = false
    
    // for Picker
    var pickIndex = Int()
    let pickerData = ["Ubike Station", "Toilet"]
    var pickerCase = PickerViewCases.Toilets
    
    @IBAction func lookForButtonTapped(sender: UIButton){
        selectionView.hidden = false
    
    
 
        
//        let selectionViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("SelectionViewController") as? SelectionViewController
//        self.addChildViewController(selectionViewController!)
//        selectionViewController!.view.frame = CGRectMake(0, self.view.frame.height-261, self.view.frame.width, 261 )
//        self.view.addSubview((selectionViewController?.view)!)
//        selectionViewController?.didMoveToParentViewController(self)
        
    }
    

 // MARK: - Action
    
    @IBAction func doneButtonTapped(sender: UIButton) {
        selectionView.hidden = true

    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        selectionView.hidden = true
    }


    @IBAction func MenuButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
// MARK: - Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        infoView.hidden = true
        selectionView.hidden = true
        getToiletAndStations()
        setView()
        setMap()
        fetchCoreData(.Toilets)
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getToiletAndStations() {
        sendAGetRequestToServer(.Toilets)
       
    }
    
    func setPickerView(){
        pickView.dataSource = self
        pickView.delegate = self
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
        pickIndex = row
//        var dataType = PickerViewCases.Toilets
        switch row {
        case 0:
            pickerCase = PickerViewCases.UbikeStations
            sendAGetRequestToServer(pickerCase)
           
        default:
            pickerCase = PickerViewCases.Toilets
            setMarkers(pickerCase)
        }
        
    }
    
    
// View
    func setView(){
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


extension MapViewController: CLLocationManagerDelegate, GMSMapViewDelegate {
    func setMap(){
        setMapDelegation()
       
    }
    
    func setMapDelegation(){
        self.mapView.delegate = self // this is for mark tapping
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            //mapView.accessibilityElementsHidden = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
//
//            let  position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)

    
//            //set camera moves
//            if let lastLocation = locations.last {
//                
//                let currentLocation = CLLocationCoordinate2DMake(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude)
//                let vancouverCam = GMSCameraUpdate.setTarget(currentLocation)
//                mapView.moveCamera(vancouverCam)
//                
//            }
            
        } else {
            let location  = CLLocationCoordinate2DMake(25.0408578889, 121.567904444)
            mapView.camera = GMSCameraPosition(target: location, zoom: 15, bearing: 0, viewingAngle: 0)
        }
        
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {

        if marker.userData != nil{
            
            if let name = marker.userData!["name"] {
                nameLabel.text = String(name!)
            }
            if let address = marker.userData!["address"] {
                addressLabel.text = String(address!)
            }
            
            if let kind = marker.userData!["kind"] {
                kindLabel.text = String(kind!)
            }
            
//            if pickerCase == PickerViewCases.UbikeStations {
//
//            } else if pickerCase == PickerViewCases.Toilets {
//                                if let bikeLeft = marker.userData!["bikeLeft"] {
//                                    kindLabel.text = String(bikeLeft!)
//                                }
//            }
//            switch Cases {
//            case .UbikeStations:

//
//            default:

//            }

        }
        
        switch infoView.hidden {
        case true :
            infoView.hidden = false
            marker.iconView.backgroundColor = UIColor.mrLightblueColor()
        default:
            infoView.hidden = true
            marker.iconView.backgroundColor = UIColor.whiteColor()
        }

        return false
    }

    func setMarkers(pickerViewData: PickerViewCases){
        setMapDelegation()
        mapView.clear()

        switch pickerViewData {
        case .Toilets:
            mapView.clear()
            if downtownToilets.count > 0 {
                for toilet in downtownToilets {
                    if locationManager.location?.distanceFromLocation(CLLocation(latitude: toilet.latitude, longitude: toilet.longitude)) < 1000 {
                        let imageViewToilet = UIImageView(image: UIImage(named: "icon-toilet"))
                        let  position = CLLocationCoordinate2DMake(toilet.latitude, toilet.longitude)
                        let marker = GMSMarker(position: position)
                        let markerBase = UIView()
                        markerBase.frame.size = CGSize(width: 40, height: 40)
                        markerBase.layer.cornerRadius = 20
                        markerBase.backgroundColor = UIColor.whiteColor()
                        imageViewToilet.frame.origin.x = markerBase.frame.origin.x + 10
                        imageViewToilet.frame.origin.y = markerBase.frame.origin.y + 10
                       
                        marker.iconView = markerBase
                        marker.title = toilet.name
                        markerBase.addSubview(imageViewToilet)
                        
                        var myData = Dictionary<String, AnyObject>()
                        myData["name"] = toilet.name
                        myData["address"] = toilet.address
                        myData["kind"] = toilet.kind
                        marker.userData = myData
                        marker.map = mapView
                    }
                }
            }
        case .UbikeStations:
            mapView.clear()
            
            //fetchCoreData(.UbikeStations)
            if stations.count > 0 {
                for station in stations {
                    if locationManager.location?.distanceFromLocation(CLLocation(latitude: station.latitude, longitude: station.longitude)) < 1000 {
                        let imageViewBike = UIImageView(image: UIImage(named: "icon-bike"))
                        let  position = CLLocationCoordinate2DMake(station.latitude, station.longitude)
                        let marker = GMSMarker(position: position)
                        let markerBase = UIView()
                        markerBase.frame.size = CGSize(width: 40, height: 40)
                        markerBase.layer.cornerRadius = 20
                        markerBase.backgroundColor = UIColor.whiteColor()
                        imageViewBike.frame.origin.x = markerBase.frame.origin.x + 5
                        imageViewBike.frame.origin.y = markerBase.frame.origin.y + 5
                        
                        marker.iconView = markerBase
<<<<<<< HEAD
                        marker.title = "\(station.bikeLeft!) bikes left"
=======
                        
                        if station.bikeLeft == "0" || station.bikeLeft == "1" {
                            marker.title = "\(station.bikeLeft!) bike left"
                        } else {
                            marker.title = "\(station.bikeLeft!) bikes left"
                        }
                        
>>>>>>> week12
                        markerBase.addSubview(imageViewBike)
                        var myData = Dictionary<String, AnyObject>()
                        myData["name"] = station.name
                        myData["address"] = station.address
                        myData["kind"] = station.dist
                        marker.userData = myData
                        marker.map = mapView

                    }
                }
            }
            
        }
    }
}

// Model
extension MapViewController: NSFetchedResultsControllerDelegate {
    func sendAGetRequestToServer(pickerViewData: PickerViewCases) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var url = ""
            switch pickerViewData {
            case .Toilets:
                url = "http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=008ed7cf-2340-4bc4-89b0-e258a5573be2"
                //            func request(URLRequest: URLRequestConvertible) -> Request {
                //                return Manager.sharedInstance.request(URLRequest.URLRequest)
            //            }
            case.UbikeStations:
                url = "http://data.taipei/youbike"
            }
            
            Alamofire.request(.GET, url)
                //.validate()
                .responseJSON {response in
                    switch response.result {
                    case .Success:
                        //print("Validation Successful")
                        if let dictionary = response.result.value{
                            print("get JSON data online sucessfull")
                           // print(dictionary)
                            self.getDataFromJson(pickerViewData, object: dictionary)
                            self.fetchCoreData(pickerViewData)
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                self.setMarkers(pickerViewData)
                                
                            })
                            //self.self.getFollowingPageData()
                            
                        } else{
                            print("get data from CoreData still")
                            //self.getDataFromCoreData()
                            //self.getStationInfoFromCoreData()
                            
                        }
                        
                    case .Failure(let error):
                        print("get data from CoreData offline")
                    }
                    
            }
        }  //end of dispatch
        //return request
    } // end of func sendAGetRequestToServer()
    
    
    // Fetch URL Data and Handle CoreData
    func cleanUpCoreData(Cases: PickerViewCases) {
        switch Cases {
        case .UbikeStations:
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                let request = NSFetchRequest(entityName: "Stations")
                do {
                    let results = try managedObjectContext.executeFetchRequest(request) as! [Stations]
                    for result in results {
                        managedObjectContext.deleteObject(result)
                    }
                    do {
                        try managedObjectContext.save()
                    }catch{
                        fatalError("Failure to save context: \(error)")
                    }
                }catch{
                    fatalError("Failed to fetch data: \(error)")
                }
            }
        default:
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                let request = NSFetchRequest(entityName: "DowntownToilet")
                do {
                    let results = try managedObjectContext.executeFetchRequest(request) as! [DowntownToilet]
                    for result in results {
                        managedObjectContext.deleteObject(result)
                    }
                    do {
                        try managedObjectContext.save()
                    }catch{
                        fatalError("Failure to save context: \(error)")
                    }
                }catch{
                    fatalError("Failed to fetch data: \(error)")
                }
            }
        }

    }
    

    func getDataFromJson(Cases: PickerViewCases ,object: AnyObject) -> AnyObject? {
        // removing the outside and middle side of info in JSon
        if let data = object as? AnyObject {
            switch Cases {
            case .UbikeStations:
                if data["retVal"] != nil {
                    let temp = data["retVal"] as! [String: AnyObject]
                    var results = [AnyObject]()
                    for t in temp {
                        results.append(t.1)
                    }
                     getInfo(.UbikeStations, results: results)
                    
                    
                } else {print ("fail in get Data from Json for Station")}

                
            default:
                //print(data["result"]!!["results"])

                if let results = data["result"]!!["results"] as? [AnyObject] {
                    getInfo(.Toilets, results: results)
                
                } else {
                    print("no toilet data")
                }
            }

            return data
        }
            
        else {
            return nil
        }
        
    } // end of fuct getStationFromJson()
    
    // Following are fuctions for getting indivual station data
    func getInfo(Cases: PickerViewCases, results: [AnyObject]) {
        switch Cases {
        case .UbikeStations:
            cleanUpCoreData(.UbikeStations)
            //print (results.count)
            
            for eachStationData in results {
                //print (eachStationData)
                if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                    station = NSEntityDescription.insertNewObjectForEntityForName("Stations", inManagedObjectContext: managedObjectContext) as! Stations

<<<<<<< HEAD
                    station.name = eachStationData["snaen"] as! String
                    station.address = eachStationData["aren"] as! String
                    station.dist = eachStationData["sareaen"] as! String
                    station.bikeLeft = eachStationData["sbi"] as! String
=======
                    station.name = eachStationData["snaen"] as? String
                    station.address = eachStationData["aren"] as? String
                    station.dist = eachStationData["sareaen"] as? String
                    station.bikeLeft = eachStationData["sbi"] as? String
>>>>>>> week12
                    
                    if let temp = eachStationData["lat"] as? String {
                        let latitude = Double(temp)
                        
                        station.latitude = latitude!
                    }
                    
                    if let temp = eachStationData["lng"] as? String {
                        let longitude = Double(temp)
                        
                        station.longitude = longitude!
                    }
                    
                    do{
                        try managedObjectContext.save()
                        
                        
                    } catch {
                        print(error)
                        return
                    }
                    
                }
                
            }
            
        default:
            cleanUpCoreData(.Toilets)

            for eachToiletData in results {
                if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                    downtownToilet = NSEntityDescription.insertNewObjectForEntityForName("DowntownToilet", inManagedObjectContext: managedObjectContext) as! DowntownToilet
                    downtownToilet.name = eachToiletData["\u{55ae}\u{4f4d}\u{540d}\u{7a31}"] as? String
                    downtownToilet.address = eachToiletData["\u{5730}\u{5740}"] as? String
                    downtownToilet.kind = eachToiletData["\u{985e}\u{5225}"] as? String
                    
                    if let temp = eachToiletData["\u{7def}\u{5ea6}"] as? String {
                        let latitude = Double(temp)
                        
                        downtownToilet.latitude = latitude!
                    }
                    
                    if let temp = eachToiletData["\u{7d93}\u{5ea6}"] as? String {
                        let longitude = Double(temp)
                        
                        downtownToilet.longitude = longitude!
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
        
    }
    
    func fetchCoreData(Cases: PickerViewCases){
        switch Cases {
        case .UbikeStations:
            let fetchRequest = NSFetchRequest(entityName: "Stations")
            let sortData = NSSortDescriptor(key: "latitude", ascending: true)
            fetchRequest.sortDescriptors = [sortData]
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                
                fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                fetchResultController.delegate = self
                
                do {
                    //performBlockAndWait
                    try fetchResultController.performFetch()
                    
                    stations = fetchResultController.fetchedObjects as! [Stations]
                    print (stations.count)
                    
                    
                } catch {
                    print(error)
                }
            }
            
        default:
            let fetchRequest = NSFetchRequest(entityName: "DowntownToilet")
            let sortData = NSSortDescriptor(key: "latitude", ascending: true)
            fetchRequest.sortDescriptors = [sortData]
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                
                fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                fetchResultController.delegate = self
                
                do {
                    //performBlockAndWait
                    try fetchResultController.performFetch()
                    
                    downtownToilets = fetchResultController.fetchedObjects as! [DowntownToilet]
                    //print(downtownToilets)
                    
                } catch {
                    print(error)
                }
            }
        }

    }

}



