//
//  HistoryViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/24.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, IndexDelegate {
    
    // variables for giving indexPath
    
    let StatisticRecord = StatisticsViewController()
    var index = 0
    
    var isPresented = false
    // variables for CorData
    var fetchResultController: NSFetchedResultsController!
    var fetchResultController1: NSFetchedResultsController!
    var record: Record!
    var records: [Record] = []
    var locations: [Locations] = []
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //StatisticRecord.delegate = self
        fetchCoreData()
        setView()
        
    }
    

    @IBAction func MenuButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 12
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print (records.count)
        var number = 0
        if records.count > 0 {
            number = records.count
        } else {
            number = 0
        }
        
        return number

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let Cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath) as! HistoryTableViewCell
        
        // get Date
        if records.count > 0 {
            print(records[indexPath.row].date)
            let NSDateFormate = String(records[indexPath.row].date)
            let recordYear = NSDateFormate.substringWithRange(Range<String.Index>(NSDateFormate.startIndex.advancedBy(0) ..< NSDateFormate.startIndex.advancedBy(4)))
            let recordMonth = NSDateFormate.substringWithRange(Range<String.Index>(NSDateFormate.startIndex.advancedBy(5) ..< NSDateFormate.startIndex.advancedBy(7)))
            let recordDate = NSDateFormate.substringWithRange(Range<String.Index>(NSDateFormate.startIndex.advancedBy(8) ..< NSDateFormate.startIndex.advancedBy(10)))
            
            print(recordYear)
            print(recordMonth)
            print(recordDate)
            
            Cell.date.text = recordDate
            
            // set th
            if recordDate == "01"  || recordDate == "21" || recordDate ==  "31" {
                Cell.th.text = "st"
            } else if recordDate == "02" || recordDate == "02" || recordDate ==  "22"  {
                Cell.th.text = "nd"
            }  else if recordDate == "03"  || recordDate == "23" {
                Cell.th.text = "rd"
            }
            
            // get distance
            let distanceInM = records[indexPath.row].distance
            let distanceInKm = distanceInM / 1000
            Cell.distance.text = String(format:"%.2f km",(distanceInKm))
            
            //get time
            if let time = records[indexPath.row].timeDuration {
                let timeText = String(time.characters.dropLast(3))
                Cell.timeDuration.text = timeText
            }
        }
        return Cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){

       let statisticsViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("StatisticsViewController") as? StatisticsViewController
        
        index = indexPath.row
        statisticsViewController?.isPresented = false
        statisticsViewController!.delegate = self
        self.navigationController?.pushViewController(statisticsViewController!, animated: true)
    }
    
    func giveIndex(cell: StatisticsViewController) -> Int {
        StatisticRecord.index = index
        
        return StatisticRecord.index
    }
    
    
    func setView(){
        setNavigationBar()

    }
    
    func setNavigationBar(){
        //set navBar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mrLightblueColor()
        self.navigationController?.navigationBar.translucent = false
        
        // delete the shadow
        let shadowImg = UIImage()
        self.navigationController?.navigationBar.shadowImage = shadowImg
        self.navigationController?.navigationBar.setBackgroundImage(shadowImg, forBarMetrics: .Default)
        
    }
    
    
    // Model
    
    func fetchCoreData(){
        let fetchRequest = NSFetchRequest(entityName: "Record")
        let sortData = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortData]
        
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            print("will fetch")
            
            do {
                try fetchResultController.performFetch()
                records = fetchResultController.fetchedObjects as! [Record]
                

                print("done fetching")
                //getIndivualValueFromCoreData()
                
                
                
            } catch {
                print(error)
            }
        }




    }
    
//    func getIndivualValueFromCoreData(){
//        if records.count > 0 {
//            for record in records {
//                print("*********")
//                print (record.timeDuration.characters.count)
//            }
//
//        }
//        
//    }

// HistoryCell
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
