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


class LoginPageViewController: UIViewController, UITextFieldDelegate {
    let gradientLayer = CAGradientLayer()
    
    // set FB button
//    let loginButton: FBSDKLoginButton = {
//        let button = FBSDKLoginButton()
//        button.readPermissions = ["public_profile","email"]
//        return button
//        
//    }()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var height: UITextField!
    
    @IBOutlet weak var weight: UITextField!
    
    weak var delegate: UITextFieldDelegate?
    
    var userHeight: Double = 0.0
    var userWeight: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
        weight.delegate = self
        height.delegate = self

        
//        if hight.secureTextEntry


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if height == textField {
            print("height")
            if let number = Double(textField.text!){
                userHeight = number
            }
        } else if  weight == textField {
            if let number = Double(textField.text!){
                userWeight = number
            }
        }
        print(userHeight)
        print(userWeight)
        print(textField)
//        if let number = Double(textField.text){
//            
//        }
//        
        return false
    }
    
    func setGradientBackground(){
        gradientLayer.frame = self.view.bounds
        let color1 = UIColor(red: 99/255, green: 215/255, blue: 246/255, alpha: 1).CGColor
        let color2 = UIColor(red: 4/255, green: 20/255, blue: 25/255, alpha: 0.5).CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.5, 1.0]
        scrollView.layer.insertSublayer(gradientLayer, atIndex: 2)
        
    }
    
    func setFBLoginButton(){
        

    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */



// MARK: - Action
extension LoginPageViewController {
    
//    @IBAction func weightButtonClicked(sender: AnyObject) {
//        weight.resignFirstResponder()
//        print(weight.text)
//        print(weight)
//        
//        
//    }
    @IBAction func loginButtonTapped(sender: AnyObject) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile"], handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
                        if error != nil {
                            NSLog(error.localizedFailureReason!)
            
                        } else if result.isCancelled {
                            NSLog("Canceled")
            
                        } else if result.grantedPermissions.contains("publish_actions") {
                            self.loginButton.hidden = true
                        }  
                    })

//        login.logInWithPublishPermissions(["publish_actions"], fromViewController: self, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
//            if error != nil {
//                NSLog(error.localizedFailureReason!)
//                
//            } else if result.isCancelled {
//                NSLog("Canceled")
//                
//            } else if result.grantedPermissions.contains("publish_actions") {
//                self.loginButton.hidden = true
//            }  
//        })

    }
}


