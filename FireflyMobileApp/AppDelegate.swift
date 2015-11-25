//
//  AppDelegate.swift
//  FireflyMobileApp
//
//  Created by ME-Tech Mac User 1 on 11/16/15.
//  Copyright © 2015 Me-tech. All rights reserved.
//

import UIKit
import MFSideMenu

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        load()
        UINavigationBar.appearance().barTintColor = UIColor(red: 240.0/255.0, green: 109.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().translucent = false
        // Override point for customization after application launch.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let container = storyboard.instantiateViewControllerWithIdentifier("MFSideMenuContainerViewController") as! MFSideMenuContainerViewController
        
        self.window?.rootViewController = container
        
        let sideMenuVC = storyboard.instantiateViewControllerWithIdentifier("sideMenuVC") as! SideMenuTableViewController
        
        let homeStoryBoard = UIStoryboard(name: "Home", bundle: nil)
        let navigationController = homeStoryBoard.instantiateViewControllerWithIdentifier("NavigationVC") as! UINavigationController
        
        container.leftMenuViewController = sideMenuVC
        container.centerViewController = navigationController
        
        container.leftMenuWidth = UIScreen.mainScreen().applicationFrame.size.width - 100

        return true
    }
    
    func load(){
        
        let request = WSDLNetworkManager()
        let parameters:[String:AnyObject] = [
            "signature": "",
            "username": "",
            "password": "",
            "sdkVersion": "",
            "version": "",
            "deviceId": "",
            "brand": "",
            "model": "",
            "dataVersion": "",
        ]
        
        request.sharedClient().createRequestWithService("Loading", withParams: parameters) { (result) -> Void in
            if result.isKindOfClass(NSDictionary){
            let title = result["dataTitle"] as! NSArray
            let flight = result["dataMarket"] as! NSArray
            let country = result["dataCountry"] as! NSArray
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            defaults.setObject(title, forKey: "title")
            defaults.setObject(flight, forKey: "flight")
            defaults.setObject(country, forKey: "country")
            
            defaults.synchronize()
            }
        }
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

