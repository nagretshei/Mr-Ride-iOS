//
//  LoginPageViewController.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/6/27.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import Amplitude_iOS


class LoginPageViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var height: UITextField!
    
    @IBOutlet weak var weight: UITextField!
    
    weak var delegate: UITextFieldDelegate?
    
    let gradientLayer = CAGradientLayer()
    var userDefault = NSUserDefaults.standardUserDefaults()
    var userHeight: Double = 0.0
    var userWeight: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Amplitude.instance().printEventsCount()
        setGradientBackground()
        weight.delegate = self
        height.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        if textField.text?.characters.count > 0 && textField.text?.characters.count < 7 {
            if height == textField {
                print("height")
                if let number = Double(textField.text!){
                    userDefault.setDouble(number, forKey: "userHeight")
                    
                } else {
                    let alert = UIAlertView.init(title: "Notification", message: "Please enter numbers only", delegate: self, cancelButtonTitle: "Ok")
                    alert.show()
                  
                }
                
            } else if  weight == textField {
                if let number = Double(textField.text!){
                    userDefault.setDouble(number, forKey: "userWeight")
                }  else {let alert = UIAlertView.init(title: "Notification", message: "Please enter numbers only", delegate: self, cancelButtonTitle: "Ok")
                    alert.show()
                   
                }
            }
            
        } else {
            let alert = UIAlertView.init(title: "Notification", message: "Please don't enter more than 6 characters", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
           
        }
        
        userDefault.synchronize()
        let theight = userDefault.doubleForKey("userHeight")
        let tweight = userDefault.doubleForKey("userWeight")
        print(theight, tweight)

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.characters.count > 0 && textField.text?.characters.count < 7 {
            if height == textField {
                print("height")
                if let number = Double(textField.text!){
                    userDefault.setDouble(number, forKey: "userHeight")
                    
                } else {
                    let alert = UIAlertView.init(title: "Notification", message: "Please enter numbers only", delegate: self, cancelButtonTitle: "Ok")
                    alert.show()
                    return false
                }
                
            } else if  weight == textField {
                if let number = Double(textField.text!){
                    userDefault.setDouble(number, forKey: "userWeight")
                }  else {let alert = UIAlertView.init(title: "Notification", message: "Please enter numbers only", delegate: self, cancelButtonTitle: "Ok")
                    alert.show()
                    return false
                }
            }

            
        } else {
            let alert = UIAlertView.init(title: "Notification", message: "Please don't enter more than 6 characters", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
            return false
        }
        
        userDefault.synchronize()
        return true
    }
    
    func setGradientBackground(){
        gradientLayer.frame = self.view.bounds
        let color1 = UIColor(red: 99/255, green: 215/255, blue: 246/255, alpha: 1).CGColor
        let color2 = UIColor(red: 4/255, green: 20/255, blue: 25/255, alpha: 0.5).CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.5, 1.0]
        scrollView.layer.insertSublayer(gradientLayer, atIndex: 2)
        
    }

}


// MARK: - Action
extension LoginPageViewController {

    @IBAction func loginButtonTapped(sender: AnyObject) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile"], fromViewController: self, handler:  { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if error != nil {
                NSLog(error.localizedFailureReason!)
                
            } else if result.isCancelled {
                NSLog("Canceled")
                
            } else if result.grantedPermissions.contains("public_profile") {
                print(3)
                self.getToViewController()
               
            } else {
            print ("unknown error in loggin Facebook")}
        })

    }
    
    func getToViewController(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let theviewController = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        
        
        let centerViewContainer = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        let menuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SideMenuViewController") as! SideMenuViewController
        
        let menuSideNav = UINavigationController(rootViewController: menuViewController)
        let centerNav = UINavigationController(rootViewController: centerViewContainer)
        
        appDelegate.centerContainer = MMDrawerController(centerViewController: centerNav, leftDrawerViewController: menuSideNav)
        
        appDelegate.centerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        appDelegate.centerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView
        
        appDelegate.centerContainer?.setMaximumLeftDrawerWidth(260, animated: true, completion: nil)
        
        appDelegate.window!.rootViewController = appDelegate.centerContainer
        appDelegate.window!.makeKeyAndVisible()
        
        //                self.view.window?.rootViewController = theviewController

    }
}


