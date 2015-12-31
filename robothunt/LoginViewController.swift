//
//  FirstViewController.swift
//  robothunt
//
//  Created by Anton McConville on 2015-12-27.
//  Copyright © 2015 IBM. All rights reserved.
//

import UIKit
import TwitterKit


class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
//                let alert = UIAlertController(title: "Logged In",
//                    message: "User \(unwrappedSession.userName) has logged in",
//                    preferredStyle: UIAlertControllerStyle.Alert
//                    
//                )
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                self.presentViewController(alert, animated: true, completion: nil)
                
                
                
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
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
        
        
        
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
                
                let status = ["name":name,"disruptionSeconds":"","timestamp":"","status":"wanted","steps":0]
                
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

