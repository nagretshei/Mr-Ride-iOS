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


class LoginPageViewController: UIViewController {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        let login = FBSDKLoginManager()
        login.logInWithPublishPermissions(["public_profile", "publish_actions"], fromViewController: self, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if error != nil {
                NSLog(error.localizedFailureReason!)
            } else if result.isCancelled {
                NSLog("Canceled")
            } else if result.grantedPermissions.contains("publish_actions") {
                //self.loginFacebookButtin.hidden = true
            }  
        })
        
        
//        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//        [login
//        logInWithReadPermissions: @[@"public_profile"]
//        fromViewController:self
//        handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//        if (error) {
//        NSLog(@"Process error");
//        } else if (result.isCancelled) {
//        NSLog(@"Cancelled");
//        } else {
//        NSLog(@"Logged in");
//        }
//        }];
    }
}


