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
    
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var Picker: UIPickerView!
    
     var fetchResultController: NSFetchedResultsController!
    
    // set toilet data variables for CoreData
    var downtownToilet: DowntownToilet!
    var downtownToilets: [DowntownToilet] = []
    
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
        infoView.hidden = true
        getToiletAndStations()
        setView()
        setMap()
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.fetchCoreData()
            dispatch_async(dispatch_get_main_queue(), {
                self.setMarkers()
                
            })
        }
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
            
            
            
////            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
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

    func setMarkers(){
        setMapDelegation()
        mapView.clear()
        
        if downtownToilets.count > 0 {
            for toilet in downtownToilets {
                if locationManager.location?.distanceFromLocation(CLLocation(latitude: toilet.latitude, longitude: toilet.longitude)) < 1000 {
                    let  position = CLLocationCoordinate2DMake(toilet.latitude, toilet.longitude)
                    let marker = GMSMarker(position: position)
                   // marker.icon = UIImage(named: "icon-toilet")
                    let imageView = UIImageView(image: UIImage(named: "icon-toilet"))
                    let markerBase = UIView()
                    
                    markerBase.frame.size = CGSize(width: 40, height: 40)
                    
                    markerBase.layer.cornerRadius = 20
                    markerBase.backgroundColor = UIColor.whiteColor()
                    imageView.frame.origin.x = markerBase.frame.origin.x + 10
                    imageView.frame.origin.y = markerBase.frame.origin.y + 10
                    markerBase.addSubview(imageView)
                    
                    
                    marker.iconView = markerBase
                    marker.title = toilet.name
                    
                    var myData = Dictionary<String, AnyObject>()
                    myData["name"] = toilet.name
                    myData["address"] = toilet.address
                    myData["kind"] = toilet.kind
                    marker.userData = myData
                    marker.map = mapView
                }
               
                
                
            }
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
                            
                        } else{
                            print("get data from CoreData still")
                            
                        }
                        
                    case .Failure(let error):
                        
                        print("get data from CoreData offline")
                        self.fetchCoreData()
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            self.setMarkers()
                            
                        })
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


            return data
        }
        else {return nil}
        
    } // end of fuct getStationFromJson()
    
    // Following are fuctions for getting indivual station data
    func getInfo(results: [AnyObject]) {
        cleanUpCoreData()
        for eachToiletData in results {
            // save eachData in CoreData
            //print(eachToiletData)
                
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                downtownToilet = NSEntityDescription.insertNewObjectForEntityForName("DowntownToilet", inManagedObjectContext: managedObjectContext) as! DowntownToilet
                downtownToilet.name = eachToiletData["\u{55ae}\u{4f4d}\u{540d}\u{7a31}"] as! String
                downtownToilet.address = eachToiletData["\u{5730}\u{5740}"] as! String
                downtownToilet.kind = eachToiletData["\u{985e}\u{5225}"] as! String
                
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
                //print(downtownToilets)
                
            } catch {
                print(error)
            }
        }
    }

}



