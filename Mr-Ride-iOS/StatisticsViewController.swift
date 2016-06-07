//
//  StatisticsViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/26.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import CoreData

class StatisticsViewController: UIViewController, NSFetchedResultsControllerDelegate {
    // variables for CorDate
    var fetchResultController: NSFetchedResultsController!
    var record: Record!
    var records: [Record] = []

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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isPresented {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(close(_:)))
            
        }
        fetchCoreData()
        setView()

        // Do any additional setup after loading the view.
    }
    
    
    
    @objc func close(sender: AnyObject?) {
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
        distance.text = "Distance"
        distanceNum.text = "0 m"
        averageSpeed.text = "Current Speed"
        averageSpeedNum.text = "0 km / h"
        calories.text = "Calories"
        caloriesNum.text = "0 kcal"
        totalTime.text = "Total Time"
        totalTimeNum.text = "00:00:00.00"
        
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
    
    func fetchCoreData(){
        print("#######")
        let fetchRequest = NSFetchRequest(entityName: "Record")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            print("will fetch")
            
            do {
                
                //performBlockAndWait
                try fetchResultController.performFetch()
                records = fetchResultController.fetchedObjects as! [Record]
                print("$$$$$$")
                print(records)
                
            } catch {
                print(error)
            }
        }
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
