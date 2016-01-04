//
//  AppDelegate.swift
//  robothunt
//
//  Created by Anton McConville on 2015-12-27.
//  Copyright © 2015 IBM. All rights reserved.
//

import UIKit

import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var playerName: String!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Twitter.self])
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //Optionally add to ensure your credentials are valid:
        FBSDKLoginManager.renewSystemCredentials { (result:ACAccountCredentialRenewResult, error:NSError!) -> Void in
            //
        }
        
        do {
            
            
            let fileManager = NSFileManager.defaultManager()
            
            let documentsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
            
            let storeURL = documentsDir.URLByAppendingPathComponent("cloudant-sync-datastore")
            let path = storeURL.path
            
            let manager = try CDTDatastoreManager(directory: path)
            let datastore = try manager.datastoreNamed("my_datastore")
            
            // Create and start the replicator -- -start is essential!
            let replicatorFactory = CDTReplicatorFactory(datastoreManager: manager)
            
            let s = "https://b7f324fb-f822-442d-8ea0-3bdba66c1934-bluemix:84ddf2db1317b0318c6e6b5c9029749c490db06274b581a153f7627fca68a1bd@b7f324fb-f822-442d-8ea0-3bdba66c1934-bluemix.cloudant.com/robots"
            let remoteDatabaseURL = NSURL(string: s)
            
            // Replicate from the local to remote database
            let pullReplication = CDTPullReplication(source: remoteDatabaseURL , target: datastore)
            let replicator =  try replicatorFactory.oneWay(pullReplication)
            
            // Start the replicator
            try replicator.start()
            
            while replicator.isActive() {
              print(replicator.state)
            }

            
            
        } catch {
            print("Encountered an error: \(error)")
        }
        

        return true
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject?) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
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
        
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

