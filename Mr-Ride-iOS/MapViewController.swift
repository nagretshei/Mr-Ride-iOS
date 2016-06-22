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
    
}


class MapViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var Picker: UIPickerView!
    
     var fetchResultController: NSFetchedResultsController!
    
    // set toilet data variables for CoreData
    var downtownToilet: DowntownToilet!
    var downtownToilets: [DowntownToilet] = []
    
//    // Set array from coredata for usage
//    var addressArray = [String]()
//    var nameArray = [String]()
//    var kindArray = [String]()
//    var latitudeArray = [Double]()
//    var longitudeArray = [Double]()
    
    // for map
    let locationManager = CLLocationManager()
    var myPath = GMSMutablePath()
    var myTotalPath = [GMSMutablePath]()
    var startToRecordMyPath = false
    
    // for Picker
    let pickerData = ["Ubike Station", "Toilet"]
    
    @IBAction func lookForButtonTapped(sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchCoreData()
        getToiletAndStations()
        setView()
        setMap()
//        fetchCoreData()
//        setMarkers()
//        setMarkers()


        //setPickerView()
    }


    @IBAction func MenuButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getToiletAndStations() {
        sendAGetRequestToServer()
       
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
    
    
// View
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
            //mapView.accessibilityElementsHidden = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            
//            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            let  position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//            let marker = GMSMarker(position: position)
//            marker.icon = UIImage(named: "icon-toilet")
////            marker.icon =
////                .markerImageWithColor = UIColor.blueColor()
//            marker.map = mapView
            

            
            
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
    func setMarkers(){
        setMapDelegation()
        
       let  position = CLLocationCoordinate2DMake(25.033408000000001, 121.564099)
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(named: "icon-toilet")
        marker.map = mapView
        
        
        for toilet in downtownToilets {
            let  position = CLLocationCoordinate2DMake(toilet.latitude, toilet.longitude)
            let marker = GMSMarker(position: position)
            marker.icon = UIImage(named: "icon-toilet")
            marker.map = mapView
        }
    }
}

// Model
extension MapViewController: NSFetchedResultsControllerDelegate {
    func sendAGetRequestToServer(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // request Json file from internet
            //let code = self.SetJWTCode()
            let url = "http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=008ed7cf-2340-4bc4-89b0-e258a5573be2"
            
            Alamofire.request(.GET, url)
                //.validate()
                .responseJSON {response in
                    switch response.result {
                    case .Success:
                        //print("Validation Successful")
                        if let dictionary = response.result.value{
                            print("get JSON data online sucessfull")
                           // print(dictionary)
                            self.getToiletFromJson(dictionary)
                            self.fetchCoreData()
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                self.setMarkers()
                                
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
    } // end of func sendAGetRequestToServer()
    
    
    // Fetch URL Data and Handle CoreData
    func cleanUpCoreData() {
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
    

    func getToiletFromJson(object: AnyObject) -> AnyObject? {
        // removing the outside and middle side of info in JSon
        if let data = object as? AnyObject {
            if let results = data["result"]!!["results"] as? [AnyObject] {
                
                // abstracting individual info from Json we need
                getInfo(results)
                
                
            } else {
                print("no toilet data")
            }
            
            
//            if dataOB["paging"] != nil {
//                let paging = dataOB["paging"] as! [String: String]
//                if paging["next"] != nil {
//                    nextURL = paging["next"]!
//                } else if paging["next"] == nil {
//                    next = true
//                }
//            }

            return data
        }
        else {return nil}
        
    } // end of fuct getStationFromJson()
    
    // Following are fuctions for getting indivual station data
    func getInfo(results: [AnyObject]) {
        cleanUpCoreData()
        for eachToiletData in results {
            // save eachData in CoreData
                
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                downtownToilet = NSEntityDescription.insertNewObjectForEntityForName("DowntownToilet", inManagedObjectContext: managedObjectContext) as! DowntownToilet
                downtownToilet.name = eachToiletData["\u{55ae}\u{4f4d}\u{540d}\u{7a31}"] as! String
                downtownToilet.address = eachToiletData["\u{5730}\u{5740}"] as! String
                downtownToilet.kind = eachToiletData["\u{884c}\u{653f}\u{5340}"] as! String
                
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
            
                // put data in array for further using
//                addressArray.append(address)
//                nameArray.append(name)
//                kindArray.append(kind)
//                latitudeArray.append(latitude)
//                longitudeArray.append(longitude)
//
                
//                let subtitle = eachCellData["aren"] as! String
//                addressSubtitle.append(String(subtitle))
//                station.addressSubtitle = String(subtitle)
//
//                
//                // support languages
//                let userLanguage = NSLocale.preferredLanguages()[0]
//                if userLanguage.containsString("zh"){
//                    let dist = eachCellData["sarea"] as! String
//                    let exit = eachCellData["sna"] as! String
//                    address.append(String(dist + " / " + exit))
//                    station.addressEn = String(dist + " / " + exit)
//                    let subtitle = eachCellData["ar"] as! String
//                    addressSubtitle.append(String(subtitle))
//                    station.addressSubtitleEn = String(subtitle)
//                }
//                
//                do {
//                    try managedObjectContext.save()
//                } catch {
//                    print(error)
//                    return
//                }
            }
            
            
        }

        // 執行 dispatch
//        dispatch_async(dispatch_get_main_queue(),{
//            
//            
////            self.mapView.startRendering()
//  
//            //self.locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
////            // update some UI
////            self.setStationVariables()
//            //self.viewDidLoad()
//            
//            
//            
//        })
       
        
    }
    func fetchCoreData(){
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
                print(downtownToilets)
                
            } catch {
                print(error)
            }
        }
    }

}



