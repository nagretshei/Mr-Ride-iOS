//
//  HistoryViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/24.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import CoreData
import Charts

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IndexDelegate {
    // variables for chart
    @IBOutlet weak var lineChartView: LineChartView!
    var xForDate =  [String]()
    var yForDistance = [Double]()
    var timeForData = [NSDate]()
    
    // variables for giving indexPath
    
    let StatisticRecord = StatisticsViewController()
    var index = 0
    
    var isPresented = false
    // variables for CorData
    var fetchResultController: NSFetchedResultsController!
    //var fetchResultController1: NSFetchedResultsController!
    var record: Record!
    var records: [Record] = []
    var locations: [Locations] = []
    
    //variables for view
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCoreData()
        setView()
        setChartView(xForDate, values: yForDistance)
    }
    

    @IBAction func MenuButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    deinit {
        print("HistoryViewController is dead")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
// set table view
    
    // set table view header
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 45))
        
        let whiteView = UIView(frame: CGRectMake(0, 10, tableView.bounds.size.width, 24))
        
        let headerLabel = UILabel(frame: CGRectMake(20, 10, tableView.bounds.size.width, 24))
        
        whiteView.backgroundColor = UIColor.whiteColor()
        headerLabel.backgroundColor = UIColor.whiteColor()
        
        
        let sections = fetchResultController.sections!

        if sections.count > 0 {
            headerLabel.text = sections[section].name
        } else {
            headerLabel.text = "month"
        }
        
        //print(fetchResultController.sectionNameKeyPath)
        headerLabel.textColor = UIColor.mrDarkSlateBlueColor()
        headerLabel.font = UIFont.mrTextStyle12Font()
        
        headerView.backgroundColor = UIColor.clearColor()
        headerView.addSubview(whiteView)
        headerView.addSubview(headerLabel)
        
        
        return headerView
    }
    

    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {

        let myRecord = fetchResultController.objectAtIndexPath(indexPath) as! Record
        let date =  myRecord.valueForKey("date") as! NSDate
        
        timeForData.append(date)
        
        let DateFormatter = NSDateFormatter()
        DateFormatter.dateFormat = "M/dd"
        let dateStamp = DateFormatter.stringFromDate(date)
        
        // slide up with inserting, slide down with apend
        if timeForData.count > 0 {
            if date.compare(timeForData[0]) == .OrderedAscending {
                xForDate.insert(dateStamp, atIndex: 0)
                let distanceInM = myRecord.valueForKey("distance") as! Double
                let distanceInKm = distanceInM / 1000
                yForDistance.insert(distanceInKm, atIndex: 0)
                //print ("before")
                if xForDate.count > 7 {
                    xForDate.removeLast()
                    timeForData.removeLast()
                }
                
                if yForDistance.count > 7 {
                    xForDate.removeLast()
                }
                
                setChartView(xForDate, values: yForDistance)
            } else if date.compare(timeForData[0]) == .OrderedDescending {
                xForDate.append(dateStamp)
                let distanceInM = myRecord.valueForKey("distance") as! Double
                let distanceInKm = distanceInM / 1000
                yForDistance.append(distanceInKm)
                
                if xForDate.count > 7 {
                    xForDate.removeFirst()
                    timeForData.removeFirst()
                }
                
                if yForDistance.count > 7 {
                    xForDate.removeFirst()
                }
                print("after")
                setChartView(xForDate, values: yForDistance)
            }
            
        }
        

        
        
        
        // Populate cell from the NSManagedObject instance
   
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if fetchResultController.sections!.count > 0  {
            return fetchResultController.sections!.count
        }
        else {return 1}
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchResultController.sections!.count > 0  {
            let sections = fetchResultController.sections!
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        } else {
            return 0
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let Cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath) as! HistoryTableViewCell
        
        configureCell(Cell, indexPath: indexPath)
        let sections = fetchResultController.sections!
        let aRecord = fetchResultController.objectAtIndexPath(indexPath)
        
        // get Date
        if sections.count > 0  {
           
            let date =  aRecord.valueForKey("date")
            let DateFormatter = NSDateFormatter()
            DateFormatter.dateFormat = "dd"
            let dateStamp = DateFormatter.stringFromDate(date! as! NSDate)

            Cell.date.text = String(dateStamp)
            
            
            // set th
            if dateStamp == "01"  || dateStamp == "21" || dateStamp ==  "31" {
                Cell.th.text = "st"
            } else if dateStamp == "02" || dateStamp == "02" || dateStamp ==  "22"  {
                Cell.th.text = "nd"
            }  else if dateStamp == "03"  || dateStamp == "23" {
                Cell.th.text = "rd"
            }

            // get distance
            let distanceInM = aRecord.valueForKey("distance") as! Double
            let distanceInKm = distanceInM / 1000
            Cell.distance.text = String(format:"%.2f km",(distanceInKm))
           

            //get time
            if let time = aRecord.valueForKey("timeDuration") {
                let timeText = String(String(time).characters.dropLast(3))
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
        setGradientBackground()
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
    
    func setGradientBackground(){
        gradientLayer.frame = self.view.bounds
        let color1 = UIColor(red: 99/255, green: 215/255, blue: 246/255, alpha: 1).CGColor
        let color2 = UIColor(red: 4/255, green: 20/255, blue: 25/255, alpha: 0.5).CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.5, 1.0]
        
        self.view.layer.insertSublayer(gradientLayer, atIndex: 1)
        
    }
    
    
    
    func setChartView(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "")
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        lineChartDataSet.mode = .CubicBezier
        
        
        //fill gradient for the curve
        let gradientColors = [UIColor.mrBrightSkyBlueColor().CGColor, UIColor.mrTurquoiseBlueColor().CGColor]
        let colorLocations:[CGFloat] = [0.0, 0.3] // Positioning of the gradient
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), gradientColors, colorLocations) // Gradient Object
        lineChartDataSet.fill = ChartFill.fillWithLinearGradient(gradient!, angle: 90.0)
        lineChartDataSet.drawFilledEnabled = true
        lineChartDataSet.lineWidth = 0.0
        
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawValuesEnabled = false
 
        //make chartview not scalable and remove the interaction line
        //lineChartView.setScaleEnabled(false)
        lineChartView.userInteractionEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        
        //set display attribute
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.labelPosition = .Bottom
        lineChartView.xAxis.spaceBetweenLabels = 2
        lineChartView.xAxis.labelTextColor = UIColor.whiteColor()
        //lineChartView.leftAxis.enabled = false
        //lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        
        //only display leftAxis gridline
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.gridColor = UIColor.whiteColor()
        
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        lineChartView.legend.enabled = false  // remove legend icon
        lineChartView.descriptionText = ""   // clear description
        
        
    }

}

// Model
extension HistoryViewController: NSFetchedResultsControllerDelegate {
    func fetchCoreData(){
        let fetchRequest = NSFetchRequest(entityName: "Record")
        let monthSort = NSSortDescriptor(key: "month", ascending: false)
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [monthSort, dateSort]
        
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "month", cacheName: nil)
            fetchResultController.delegate = self
            
            print("will fetch")
            
            do {
                try fetchResultController.performFetch()
                records = fetchResultController.fetchedObjects as! [Record]
                
                
                print("done fetching")
                //print (records)
                
                
                
            } catch {
                
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        }
        
    }
    
}
