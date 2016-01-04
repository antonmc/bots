//
//  TableViewController.swift
//  robothunt
//
//  Created by Anton McConville on 2016-01-03.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var bots: NSMutableArray!
    
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        do{
            
            let fileManager = NSFileManager.defaultManager()
            
            let documentsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
            
            let storeURL = documentsDir.URLByAppendingPathComponent("cloudant-sync-datastore")
            let path = storeURL.path
            
            let manager = try CDTDatastoreManager(directory: path)
            let datastore = try manager.datastoreNamed("player")
            
            let robotstore = try manager.datastoreNamed("my_datastore")
            
            var playerFound = false
            
            
            let query = [ "name" : self.appDelegate.playerName ]
            let result = datastore.find(query)
            
            if result.documentIds.count > 0{
                
                playerFound = true
            }
            
            result.enumerateObjectsUsingBlock({ (rev, idx, stop) -> Void in
                
                let robotData = rev.body;
                
                self.bots = robotData.objectForKey("robots") as! NSMutableArray
                
                
                playerFound = true
                
            })
            
            
            if playerFound == false{
            
            }
            
            
            
        }catch {
            print("Encountered an error: \(error)")
        }

        
        
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.bots.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FruitCell", forIndexPath: indexPath) as! UITableViewCell
        
        let robotentry = self.bots[indexPath.row] as! NSMutableDictionary
        
        
        cell.textLabel?.text = robotentry.objectForKey("name") as! String
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
