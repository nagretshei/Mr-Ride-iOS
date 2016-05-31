//
//  SideMenuViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/24.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet private weak var menuTableView: UITableView!
    
    private var currectSelected = NSIndexPath(forRow: 0, inSection: 0)
   
    private let menuItems = ["Home", "History"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            let centerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
            
            let centerNavController = UINavigationController(rootViewController: centerViewController)
            
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.centerContainer!.centerViewController = centerNavController
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
         
            break
            
        case 1:
            let historyViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HistoryViewController") as! HistoryViewController
            
            let historyNavController = UINavigationController(rootViewController: historyViewController)
            
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.centerContainer!.centerViewController = historyNavController
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
