//
//  ViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/24.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // variables for CorData
    var fetchResultController: NSFetchedResultsController!
    //var totalDistance: Double = 0.0
    
    
    //var fetchResultController1: NSFetchedResultsController!
    var record: Record!
    var records: [Record] = []
    var locations: [Locations] = []
    var coreDataIsZero = true
    
    var index = 0
    
    
    // variables for View

    @IBOutlet weak var totalDistanceLabel: UILabel!

    @IBOutlet weak var totaldistanceLabel: UILabel!
    
    @IBOutlet weak var totalcountLabel: UILabel!
    
    @IBOutlet weak var totalCountLabel: UILabel!
    
    @IBOutlet weak var averagespeedLabel: UILabel!
    
    @IBOutlet weak var averageSpeedLabel: UILabel!
    
    @IBOutlet weak var letsRideButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        

    }
    
    @IBAction func MenuButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }

    
    @IBAction func letsRideButtonTapped(sender: UIButton) {
        let recordPage = storyboard?.instantiateViewControllerWithIdentifier("RecordViewController") as! RecordViewController
        let recordNavController = UINavigationController(rootViewController: recordPage)
        presentViewController(recordNavController, animated: true, completion: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // View
    func setView(){
        fetchCoreData()
        setLabelAndButton()
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
    
    func setLabelAndButton(){
        totalDistanceLabel.font = UIFont.mrTextStyle14Font()
        totaldistanceLabel.layer.shadowOpacity = 2.0
        totaldistanceLabel.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15).CGColor;
        totaldistanceLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        
        
        totalDistanceLabel.layer.shadowOpacity = 2.0
        //totalDistanceLabel.layer.shadowRadius = 0.0;
        totalDistanceLabel.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.25).CGColor;
        totalDistanceLabel.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        
        totalcountLabel.layer.shadowOpacity = 2.0
        totalcountLabel.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15).CGColor;
        totalcountLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        
        totalCountLabel.font = UIFont.mrTextStyle15Font()
        totalCountLabel.layer.shadowOpacity = 2.0
        totalCountLabel.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15).CGColor;
        totalCountLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        
        averagespeedLabel.layer.shadowOpacity = 2.0
        averagespeedLabel.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2).CGColor;
        averagespeedLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        
        averageSpeedLabel.font = UIFont.mrTextStyle15Font()
        averageSpeedLabel.layer.shadowOpacity = 2.0
        averageSpeedLabel.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15).CGColor;
        averageSpeedLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        
        
        letsRideButton.layer.shadowOpacity = 2.0
        letsRideButton.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.25).CGColor;
        letsRideButton.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        
        letsRideButton.titleLabel!.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.25)
        letsRideButton.titleLabel!.shadowOffset = CGSizeMake(0, 1.0);
        
        
        if records.count > 0 {
            totalCountLabel.text = String(format:"%.d times",records.count)
            
            let totalDistanceInKm = records[records.count-1].totalDistanceInHistory / 1000
            totalDistanceLabel.text =  String(format:"%.2f m", totalDistanceInKm)
            
            
           let totalAverageSpeed = (records[records.count-1].totalAverageSpeed / Double(records[records.count-1].count))
            averageSpeedLabel.text = String(format:"%.2f km / h", totalAverageSpeed)

        }
        
    }
    

    
    //    func addTextSpacing(){
    //        let attributedString = NSMutableAttributedString(string: self.text!)
    //        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(1.2), range: NSRange(location: 0, length: self.text!.characters.count))
    //        self.attributedText = attributedString
    //    }
    
    //        let attributedString = totalDistanceLabel.attributedText as! NSMutableAttributedString
    //        attributedString.addAttribute(NSKernAttributeName, value: 1.9, range: NSMakeRange(0, attributedString.length))
    //        totalDistanceLabel.attributedText = attributedString
    



}

// Model
extension ViewController: NSFetchedResultsControllerDelegate {
    
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
    
//    func getTotalDistance(){
////        totalDistance +=
//    }
}

