//
//  HistoryViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/24.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IndexDelegate {
    
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
    
    //variables for tableview
    var months = [String]()
    var SectionArray = [[Record]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCoreData()
        getSectionsFromData()
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
    
    
//    
//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 10
//    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 45))
        
        let whiteView = UIView(frame: CGRectMake(0, 10, tableView.bounds.size.width, 25))

        
        let headerLabel = UILabel(frame: CGRectMake(20, 10, tableView.bounds.size.width, 25))
        
        whiteView.backgroundColor = UIColor.whiteColor()
        headerLabel.backgroundColor = UIColor.whiteColor()
        headerLabel.text = months[section]
        headerLabel.textColor = UIColor.mrDarkSlateBlueColor()
        headerLabel.font = UIFont.mrTextStyle12Font()
        
        headerView.backgroundColor = UIColor.clearColor()
        headerView.addSubview(whiteView)
        headerView.addSubview(headerLabel)
        
        
        return headerView
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return months.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print (records.count)
        var number = 0
        if records.count > 0 {
            number = SectionArray[section].count
        } else {
            number = 0
        }
        
        return number

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let Cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath) as! HistoryTableViewCell
        
        // get Date
        if SectionArray.count > 0 {
            
            let date =  SectionArray[indexPath.section][indexPath.row].date
            let DateFormatter = NSDateFormatter()
            DateFormatter.dateFormat = "dd"
            let dateStamp = DateFormatter.stringFromDate(date!)

            Cell.date.text = dateStamp
            
            // set th
            if dateStamp == "01"  || dateStamp == "21" || dateStamp ==  "31" {
                Cell.th.text = "st"
            } else if dateStamp == "02" || dateStamp == "02" || dateStamp ==  "22"  {
                Cell.th.text = "nd"
            }  else if dateStamp == "03"  || dateStamp == "23" {
                Cell.th.text = "rd"
            }
            
            // get distance
            let distanceInM = SectionArray[indexPath.section][indexPath.row].distance
            let distanceInKm = distanceInM / 1000
            Cell.distance.text = String(format:"%.2f km",(distanceInKm))
            
            //get time
            if let time = SectionArray[indexPath.section][indexPath.row].timeDuration {
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
    
    
    // View
    
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

}

// Model
extension HistoryViewController: NSFetchedResultsControllerDelegate {
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
    

    
    func getSectionsFromData() {
        print(records)
        let recordsReverse = records.reverse()
        print (recordsReverse)
        
        var TempSectionArray = [[Record]]()

        //SectionArray
        if records.count > 0 {
            for item in records {
                // get section title array
                var temp = [String]()
                let monthStamp = item.month!
                temp.append(monthStamp)
                months = Array(Set(arrayLiteral: monthStamp))
            }

        }
        
        for month in months {
            var tempSection = [Record]()
            
            for item in records {
                if item.month == month {
                    tempSection.append(item)
                }
            }
            TempSectionArray.append(tempSection)
        }
        print (TempSectionArray)
    
      //didn't work for the order
        for ts in TempSectionArray.enumerate() {
            let newIndex = TempSectionArray.count - 1 - ts.index
            SectionArray.append(TempSectionArray[newIndex])
        }
        
        print(SectionArray)
        
    }
    
    
}
