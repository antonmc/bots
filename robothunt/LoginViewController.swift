//
//  FirstViewController.swift
//  robothunt
//
//  Created by Anton McConville on 2015-12-27.
//  Copyright © 2015 IBM. All rights reserved.
//

import UIKit
import TwitterKit


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var facebookView: UIView!
    @IBOutlet var twitterView: UIView!
    
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            
            self.performSegueWithIdentifier("beginSegue", sender: self)

            // User is already logged in, do work such as go to next view controller.
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            
            facebookView.addSubview(loginView)
//            facebookView.bringSubviewToFront(loginView)
//            self.view.bringSubviewToFront(loginView)
            loginView.frame.size.width = 280
            loginView.frame.size.height = 40
            

        //    loginView.center = facebookView.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
            

        }
        
        
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {

                do{
                    
                    let fileManager = NSFileManager.defaultManager()
                    
                    let documentsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
                    
                    let storeURL = documentsDir.URLByAppendingPathComponent("cloudant-sync-datastore")
                    let path = storeURL.path
                    
                    let manager = try CDTDatastoreManager(directory: path)
                    let datastore = try manager.datastoreNamed("player")
                    
                    let robotstore = try manager.datastoreNamed("my_datastore")
                    
                    var playerFound = false
                    
                    
                    let query = [ "name" : unwrappedSession.userName ]
                    let result = datastore.find(query)
                    
                    if result.documentIds.count > 0{
                        
                        playerFound = true
                        
                        self.appDelegate.playerName = unwrappedSession.userName
                    }
                    
                    result.enumerateObjectsUsingBlock({ (rev, idx, stop) -> Void in
                        
                        let robotData = rev.body;
                        
                        
                        playerFound = true

                        self.performSegueWithIdentifier("beginSegue", sender: self)
                    })
                    
                    
                    if playerFound == false{
                        self.createPlayer(unwrappedSession.userName, store: datastore, robotstore:robotstore, manager: manager)
                    }
                    

                    
                }catch {
                    print("Encountered an error: \(error)")
                }


                
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
        
        // TODO: Change where the log in button is positioned in your view
//        logInButton.center = self.view.center
        twitterView.addSubview(logInButton)
//        logInButton.center = twitterView.center

        
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
    
    
    func createPlayer(person:NSString, store:CDTDatastore, robotstore:CDTDatastore, manager:CDTDatastoreManager){
        
        let replicatorFactory = CDTReplicatorFactory(datastoreManager: manager)
        let s = "https://b7f324fb-f822-442d-8ea0-3bdba66c1934-bluemix:84ddf2db1317b0318c6e6b5c9029749c490db06274b581a153f7627fca68a1bd@b7f324fb-f822-442d-8ea0-3bdba66c1934-bluemix.cloudant.com/players";
        let remoteDatabaseURL = NSURL(string:s)
        
        let query = [ "name" : "robothunt" ]
        let result = robotstore.find(query)
        result.enumerateObjectsUsingBlock({ (rev, idx, stop) -> Void in
            
            let robotData = rev.body;
            
            let bots = robotData.objectForKey("bots") as! NSMutableArray
            
            let scorecard:NSMutableArray = []
            
            
            for bot in bots{
                
                let robot = bot as! NSMutableDictionary
                
                let name = robot.objectForKey("name") as! NSString
                
                let mugshot = robot.objectForKey("mugshotBase64") as! NSString
                
                let primaryColor = robot.objectForKey("primaryColor") as! NSString
                
                let status = ["name":name,"mugshot":mugshot, "primaryColor": primaryColor, "disruptionSeconds":"","timestamp":"","status":"wanted","steps":0]
                
                let robotStatus = (status as NSDictionary).mutableCopy() as! NSMutableDictionary

                scorecard.addObject(robotStatus)
            }
            
        
            let rev = CDTDocumentRevision()
            rev.body = ["name":person,
                "robots": scorecard,
                "type":"com.cloudant.sync.example.task"]
            do{
            
                // Save the document to the database
                
                try store.createDocumentFromRevision(rev)
            
                let pushReplication = CDTPushReplication(source: store, target: remoteDatabaseURL)
                let replicator =  try replicatorFactory.oneWay(pushReplication)
            
                // Start the replicator
                try replicator.start()
                
                while replicator.isActive() {
                    print(replicator.state)
                }

            
            }catch{
            
            }
            
            self.performSegueWithIdentifier("beginSegue", sender: self)

        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

