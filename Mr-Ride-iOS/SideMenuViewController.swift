//
//  SideMenuViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/24.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import Amplitude_iOS

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet private weak var menuTableView: UITableView!
    
    private var currectSelected = NSIndexPath(forRow: 0, inSection: 0)
   
    private let menuItems = ["Home", "History", "Map"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Amplitude.instance().logEvent("view_in_menu")
        setView()
      
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        menuTableView.selectRowAtIndexPath(currectSelected, animated: false, scrollPosition: .None)
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let myCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MenuTableViewCell
        
        myCell.dot.hidden = true
        
        myCell.menuItemLebel.text = menuItems[indexPath.row]
        myCell.backgroundColor = UIColor.clearColor()

        
        myCell.menuItemLebel.layer.shadowOpacity = 2.0
        myCell.menuItemLebel.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.25).CGColor;
        myCell.menuItemLebel.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        
        myCell.dot.layer.shadowOpacity = 2.0
        myCell.dot.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.25).CGColor;
        myCell.dot.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        
        return myCell
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        currectSelected = indexPath
        
        switch (indexPath.row) {
            
        case 0:
            Amplitude.instance().logEvent("select_home_in_menu")
            
            let centerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
            
            let centerNavController = UINavigationController(rootViewController: centerViewController)
            
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
         
            break
            
        case 1:
            Amplitude.instance().logEvent("select_history_in_menu")
            let historyViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HistoryViewController") as! HistoryViewController
            
            let historyNavController = UINavigationController(rootViewController: historyViewController)
            
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.centerContainer!.centerViewController = historyNavController
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            break;
            
        case 2:
            Amplitude.instance().logEvent("select_map_in_menu")
            let mapViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
            
            let mapNavController = UINavigationController(rootViewController: mapViewController)
            
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.centerContainer!.centerViewController = mapNavController
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            break;
            
        default:
            print("\(menuItems[indexPath.row]) is selected")
        }
    }
   

    
    func setView(){
        navigationController?.setNavigationBarHidden(true, animated: false)
        menuTableView.backgroundColor = UIColor(red: 14.0/255.0, green: 53.0/255.0, blue: 64.0/255.0, alpha: 1.0)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SideMenuViewController {
    
    @IBAction func logOutButtonTapped(sender: UIButton) {
        FBSDKAccessToken.currentAccessToken()
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.goBackToLoginPage()
        
    }
    
    func goBackToLoginPage(){
        Amplitude.instance().logEvent("select_log_out_in_menu")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let theviewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginPageViewController") as! LoginPageViewController
        
        self.view.window?.rootViewController = theviewController
    
    }
    
    
}
