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
    
    //variables for view
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCoreData()
        getSectionsFromData()
        setView()
        setHistoryChart()
    }
    

    @IBAction func MenuButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 45))
        
        let whiteView = UIView(frame: CGRectMake(0, 10, tableView.bounds.size.width, 24))
        
        let headerLabel = UILabel(frame: CGRectMake(20, 10, tableView.bounds.size.width, 24))
        
        whiteView.backgroundColor = UIColor.whiteColor()
        headerLabel.backgroundColor = UIColor.whiteColor()
        
        if SectionArray.count > 0 {
            headerLabel.text = months[section]
        }
        headerLabel.textColor = UIColor.mrDarkSlateBlueColor()
        headerLabel.font = UIFont.mrTextStyle12Font()
        
        headerView.backgroundColor = UIColor.clearColor()
        headerView.addSubview(whiteView)
        headerView.addSubview(headerLabel)
        
        
        return headerView
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return SectionArray.count
//        if fetchResultController.sections!.count > 0  {
//            return fetchResultController.sections!.count
//        }
//        else {return 1}
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print (records.count)
        var number = 0
        if records.count > 0 {
            //number = fetchResultController.sections!
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
    
        //print("history didSelect")
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
    
    
    func setHistoryChart(){
        getXandYForChart()
        setChart(xForDate, values: yForDistance)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
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
        
        


        //lineChartView.xAxis.spaceBetweenLabels =

//       // lineChartView.scaleYEnabled = true

//        lineChartView.scaleXEnabled = false
//        
//        lineChartView.descriptionTextColor = UIColor.clearColor()
//        //lineChartView.chartXMin.
        
        
        
        //setChartDimens
        
        //XAxisLabelPosition
        //xAxis.
        
        
    }

}

// Model
extension HistoryViewController: NSFetchedResultsControllerDelegate {
    func fetchCoreData(){
        let fetchRequest = NSFetchRequest(entityName: "Record")
        let sortData = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortData]
        
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "month", cacheName: nil)
            fetchResultController.delegate = self
            
            print("will fetch")
            
            do {
                try fetchResultController.performFetch()
                records = fetchResultController.fetchedObjects as! [Record]
                
                
                
                
                print("done fetching")
                print (records)
                //getIndivualValueFromCoreData()
                
                
                
            } catch {
                print(error)
            }
        }
        
    }
    

    
    func getSectionsFromData() {
        //print(records)
        let recordsReverse = records.reverse()
        //print (recordsReverse)
        
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
            SectionArray.append(tempSection)
        }
      
        //print(SectionArray)
        
    }
    func getXandYForChart(){
        if records.count > 0 {
            for item in records {
                // get XForDate
                let date =  item.date
                let DateFormatter = NSDateFormatter()
                DateFormatter.dateFormat = "M/dd"
                let dateStamp = DateFormatter.stringFromDate(date!)
                xForDate.append(dateStamp)
                
                let distance = item.distance
                yForDistance.append(distance)
                
            }
            
        }

    }
    
}
