//
//  ViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/24.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import CoreData
import Charts

class ViewController: UIViewController {
    
    @IBOutlet weak var lineChartView: LineChartView!
    var xForDate =  [String]()
    var yForDistance = [Double]()

    
    // variables for CorData
    var fetchResultController: NSFetchedResultsController!
    
    
    //var fetchResultController1: NSFetchedResultsController!
    var record: Record!
    var records: [Record] = []
    var locations: [Locations] = []
    var coreDataIsZero = true
    
    var index = 0
    var totalValue: TotalValue!
    var totalValues: [TotalValue] = []
    
    
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
        setValueForChart()
        setChartView(xForDate, values: yForDistance)

    }
    
    @IBAction func MenuButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }

    
    @IBAction func letsRideButtonTapped(sender: UIButton) {
        let recordPage = storyboard?.instantiateViewControllerWithIdentifier("RecordViewController") as! RecordViewController
        let recordNavController = UINavigationController(rootViewController: recordPage)
        //recordNavController.modalPresentationStyle = .OverCurrentContext
        
        let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
        let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
        if iOS8 {
            recordNavController.modalPresentationStyle = .OverCurrentContext
            //self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        } else {
            recordNavController.modalPresentationStyle = .CurrentContext
            //self.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        }
        
        presentViewController(recordNavController, animated: true, completion: nil)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Controller
    func setValueForChart(){
        
        if records.count > 0  {
            for record in records {
                if xForDate.count < 7 {
                    
                    let date =  record.date
                    let DateFormatter = NSDateFormatter()
                    DateFormatter.dateFormat = "dd"
                    let dateStamp = DateFormatter.stringFromDate(date! as! NSDate)
                    xForDate.append(dateStamp)
                    
                    let distanceInM = record.distance
                    let distanceInKm = distanceInM / 1000
                    yForDistance.append(distanceInKm)
                }
                    
                else {return}
            }

        }
    }
    
    
    // View
    func setView(){
        fetchCoreData()
        fetchCoreDataForTotalValue()
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
            
            if records.count == 1{
                totalCountLabel.text = String(format:"%.d time",records.count)
            } else if records.count > 1 {
                totalCountLabel.text = String(format:"%.d times",records.count)
            }
            
            if totalValues.count > 0 {
                
                let totalDistanceInKm = totalValues[totalValues.count-1].totalDistanceInHistory / 1000
                totalDistanceLabel.text =  String(format:"%.2f km", totalDistanceInKm)

                
                let totalAverageSpeed = totalValues[totalValues.count-1].totalAverageSpeed
                averageSpeedLabel.text = String(format:"%.2f km / h", totalAverageSpeed)
            }
        }
        
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
        lineChartView.setScaleEnabled(false)
        lineChartView.userInteractionEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        
        //set display attribute
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.labelPosition = .Bottom
        lineChartView.xAxis.labelTextColor = UIColor.whiteColor()
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
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
extension ViewController: NSFetchedResultsControllerDelegate {
    
    func fetchCoreData(){
        let fetchRequest = NSFetchRequest(entityName: "Record")
        let sortData = NSSortDescriptor(key: "date", ascending: false)
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
    
    func fetchCoreDataForTotalValue(){
        let fetchRequest = NSFetchRequest(entityName: "TotalValue")
        let sortData = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortData]
        
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            //print("will fetch")
            
            do {
                //performBlockAndWait
                try fetchResultController.performFetch()
                totalValues = fetchResultController.fetchedObjects as! [TotalValue]
                
            } catch {
                print(error)
            }
        }
    }
    
}

