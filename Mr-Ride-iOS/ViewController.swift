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
import Amplitude_iOS




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
    
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
//        let name = "Pattern~\(self.title!)"
//        
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: name)
//        
//        let builder = GAIDictionaryBuilder.createScreenView()
//        tracker.send(builder.build() as [NSObject : AnyObject])
//        // [END screen_view_hit_swift]
//        // The UA-XXXXX-Y tracker ID is loaded automatically from the
//        // GoogleService-Info.plist by the `GGLContext` in the AppDelegate.
//        // If you're copying this to an app just using Analytics, you'll
//        // need to configure your tracking ID here.
//        // [START screen_view_hit_swift]
//        
//        //        Analytics tracking ID
//        //        UA-5432312-1
//        //        Google Analytics Account
//        //        yicheng.zoe
//        //        Analytics Property
//                http://sites.google.com/site/nagretshei/
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Amplitude.instance().logEvent("view_in_home")
        fetchCoreData()
        fetchCoreDataForTotalValue()
        setView()
        setValueForChart()
        setChartView(xForDate, values: yForDistance)

    }
    
    @IBAction func MenuButtonTapped(sender: AnyObject) {
        Amplitude.instance().logEvent("select_menu_in_home")
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }

    
    @IBAction func letsRideButtonTapped(sender: UIButton) {
        Amplitude.instance().logEvent("select_ride_in_home")

        let recordPage = storyboard?.instantiateViewControllerWithIdentifier("RecordViewController") as! RecordViewController
        let statisticPage = storyboard?.instantiateViewControllerWithIdentifier("StatisticsViewController") as! StatisticsViewController
        
        recordPage.dismissDelegation = self
        
        
        
        let recordNavController = UINavigationController(rootViewController: recordPage)
       
        let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
        let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
        if iOS8 {
            recordNavController.modalPresentationStyle = .OverCurrentContext
            
        } else {
            recordNavController.modalPresentationStyle = .CurrentContext
            
        }
        totalDistanceLabel.hidden = true
        totaldistanceLabel.hidden = true
        totalcountLabel.hidden = true
        totalCountLabel.hidden = true
        averagespeedLabel.hidden = true
        averageSpeedLabel.hidden = true
        letsRideButton.hidden = true
        
        presentViewController(recordNavController, animated: true, completion: nil)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Controller
    func setValueForChart(){
    
        if records.count > 0  {
            xForDate.append("tomorrow")
            yForDistance.append(0)
            
            for record in records {
                if xForDate.count < 7 {
                    
                    let date =  record.date
                    let DateFormatter = NSDateFormatter()
                    DateFormatter.dateFormat = "dd"
                    let dateStamp = DateFormatter.stringFromDate(date! )
                    xForDate.insert(dateStamp, atIndex: 0)
                    
                    let distanceInM = record.distance
                    let distanceInKm = distanceInM / 1000
                    yForDistance.insert(distanceInKm, atIndex: 0)
                 
                }
                    
                else {
                    return}

            }

        }
    }
    deinit {
        print("ViewController is dead")
    }
    
    // View
    func setView(){
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
        let gradientColors =  [UIColor.mrWaterBlueColor().CGColor, UIColor.mrRobinsEggBlue0Color().CGColor]
        let colorLocations:[CGFloat] = [0.45, 0.0] // Positioning of the gradient
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), gradientColors, colorLocations) // Gradient Object
        lineChartDataSet.fill = ChartFill.fillWithLinearGradient(gradient!, angle: 90.0)
        lineChartDataSet.drawFilledEnabled = true
        lineChartDataSet.lineWidth = 0.0
        
        lineChartDataSet.drawCirclesEnabled = true
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.circleRadius = CGFloat(4.0)

        lineChartDataSet.circleColors.removeAll(keepCapacity: false)
        var i = 0
        while i < 5 {
        lineChartDataSet.circleColors.append(NSUIColor.clearColor())
            i += 1
        }
        
        
        lineChartDataSet.circleColors.append(NSUIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.7))
        
        lineChartDataSet.drawValuesEnabled = false
        
        //make chartview not scalable and remove the interaction line
        lineChartView.setScaleEnabled(false)
        lineChartView.userInteractionEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        
        //set display attribute
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.enabled = false
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

extension ViewController: DismissDelegation {
    func showLabels() {
//        setValueForChart()
//        setChartView(xForDate, values: yForDistance)
        self.viewDidLoad()

        // show UIlabels
        totalDistanceLabel.hidden = false
        totaldistanceLabel.hidden = false
        totalcountLabel.hidden = false
        totalCountLabel.hidden = false
        averagespeedLabel.hidden = false
        averageSpeedLabel.hidden = false
        letsRideButton.hidden = false
        
    }
}

