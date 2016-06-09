//
//  HistoryViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/24.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    var isPresented = false
    // variables for CorData
    var fetchResultController: NSFetchedResultsController!
    var fetchResultController1: NSFetchedResultsController!
    var record: Record!
    var records: [Record] = []
    var locations: [Locations] = []
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        print (records.count)
        var number = 10
        if records.count > 0 {
            number = records.count
        } else {
            number = 10
        }
        
        return number

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let Cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath) as! HistoryTableViewCell
        
        return Cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){

       let statisticsViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("StatisticsViewController") as? StatisticsViewController
        
        statisticsViewController?.isPresented = false
        self.navigationController?.pushViewController(statisticsViewController!, animated: true)
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
                
                
            } catch {
                print(error)
            }
        }
    }

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
