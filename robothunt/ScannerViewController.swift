//
//  FirstViewController.swift
//  robothunt
//
//  Created by Anton McConville on 2015-12-27.
//  Copyright © 2015 IBM. All rights reserved.
//

import UIKit

import PresenceInsightsSDK
import CoreLocation



class ScannerViewController: UIViewController, CLLocationManagerDelegate, PIBeaconSensorDelegate{
    
//    @IBOutlet var radar: CCMRadarView!
    @IBOutlet var imageView: UIImageView!
    
    var appDelegate:AppDelegate!
    
    var disruptionRange = 1.4
    
    var gauge:MSSimpleGauge!
    
    let locationManager = CLLocationManager()
    let tenantID = ""
    let orgID = ""
    let username = ""
    let passwd = ""
    let siteID = ""
    let floorID = ""
    let baseURL =  ""
    
    var bots: NSMutableArray!
    
    var piBeaconSensor : PIBeaconSensor!
    var piAdapter : PIAdapter!
    
    override func viewDidLoad() {
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        let pulseEffect = PulseAnimation(repeatCount: Float.infinity, radius:300, position:self.view.center)
        view.layer.insertSublayer(pulseEffect, below: imageView.layer)
        super.viewDidLoad()
        
        do{
        
            let fileManager = NSFileManager.defaultManager()
        
            let documentsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
        
            let storeURL = documentsDir.URLByAppendingPathComponent("robothunt-datastore")
            let path = storeURL.path
        
            let manager = try CDTDatastoreManager(directory: path)
            let datastore = try manager.datastoreNamed("robotDatastore")

            var test = false;
        
        
            let query = [ "name" : "robothunt" ]
            let result = datastore.find(query)
                result.enumerateObjectsUsingBlock({ (rev, idx, stop) -> Void in
                    
                    let robotData = rev.body;
                    
                     self.bots = robotData.objectForKey("bots") as! NSMutableArray
                    
                    test = true;
                    
            // do something
            })
            
            if test == false{
                
                print("false")
                
            }
            
        }catch {
            print("Encountered an error: \(error)")
        }
        
        
        
        piAdapter = PIAdapter(tenant: "ow2b9014n", org: "re40vu0prs", username: "ag2kp00bho", password: "2HQRozhN27dZ")
        
        piBeaconSensor = PIBeaconSensor(adapter: piAdapter)

        piBeaconSensor.delegate = self
        
        piBeaconSensor.start(  )
    
        
        let locationManager = CLLocationManager()
        //setting locationManager to self
        locationManager.delegate = self
        
        //checking and asking user for allowing ble location access
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse){
                locationManager.requestWhenInUseAuthorization()
        }
        
        let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
        locationManager.startRangingBeaconsInRegion(region)
        
//        self.startSensing()
        // self.getBeacons()
        
//        self.didRangeBeacons(<#T##beacons: [CLBeacon]##[CLBeacon]#>)
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.gauge = MSSimpleGauge( frame: CGRectMake(self.view.frame.size.width/2-100, 160, 200, 175) )
        
        self.gauge.fillArcFillColor = UIColor( colorLiteralRed: 0.49, green:0.812, blue:0.714, alpha:1 )
        self.gauge.backgroundColor = UIColor.clearColor()
        self.gauge.backgroundArcFillColor = UIColor( colorLiteralRed: 0.49, green:0.812, blue:0.714, alpha:0.5 )
        self.gauge.fillArcStrokeColor = UIColor.clearColor()
        self.gauge.backgroundArcStrokeColor = UIColor.clearColor()
        self.gauge.backgroundGradient = nil
        
        self.gauge.startAngle = 0
        self.gauge.endAngle = 180
        self.gauge.value = 0
        self.gauge.maxValue = 15
        
        self.gauge.arcThickness = 0.3
        
        self.gauge.needleView.needleColor = UIColor.orangeColor()
        
        self.view.addSubview(self.gauge)
        
        print(self.gauge)
    }
    
    func beaconHandler(){
        
    }
    
    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        radar.startAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startSensing() {
        
        //sdk call for start sensing
        //call back is necessary
        piBeaconSensor.start { (NSError) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(NSError == nil){
                    self.alert("Success", messageInput: "Started Sensing for Beacons")
                }
                else{
                    self.alert("Error", messageInput: "\(NSError)")
                }
            })
        }
    }
    
    @IBAction func stopSensing() {
        //sdk call to stop beacon sensing
        piBeaconSensor.stop()
        alert("Success", messageInput: "Successfully stopped sensing for beacons")
        
    }
    
    @IBAction func getUUID(sender: UIButton) {
        
        //getes UUID from PI instance
        piAdapter.getAllBeaconRegions { (uuids, NSError) -> () in
            // Do whatever you want with the beacon UUIDs here.
            
            //for this app, we will pop up message with the list of UUIDs
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(NSError == nil){
                    self.alert("UUIDS", messageInput: "UUID: \(uuids)")
                }
                else{
                    self.alert("Error", messageInput: "\(NSError)")
                }
            })
        }
    }
    
    @IBAction func getBeacons() {
        
        piAdapter.getAllBeacons(siteID, floor: floorID) { (beacons, NSError) -> () in
            //you can do whatever you want with the beacons that returned.
            //for demo purposes will display number of beacons
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(NSError == nil){
                    let num = beacons.count
                    self.alert("Number of Beacons", messageInput: "Total number of beacons for the floor: \(num)")
                }
                else{
                    self.alert("Error", messageInput: "\(NSError)")
                }
            })
            
        }
        
        
    }
    
    
    func didRangeBeacons(beacons: [CLBeacon]) {
        // Do whatever you want with the ranged beacons here.
        //anything you want to locally on the app goes here
        
        
        if let beacon:CLBeacon = beacons.first{
        
            if let minor:NSNumber = beacon.minor{
                
                print( "FIRST BEACON: ")
        
                if let distance:Float = Float(beacon.accuracy){
            
                    print( minor )
            
                    print( distance )
        
                    if distance > 0 {
            
                        if( distance > Float(self.disruptionRange) ){
            
                            self.gauge.value = self.gauge.maxValue - distance
                    
                            
                           //                            print( bot.objectForKey("status") as! NSString )
            
                        }else{
//                          self.performSegueWithIdentifier("robotsegue", sender: self)
//                          self.stopSensing()
                            
                            let bot = self.identifyRobot(minor)
                            
                            if self.omitRobot(self.appDelegate.playerName){
                                print( "this robot has been disrupted" )
                            }else{
                                print( "this robot has not been disrupted")
                            }
                            
                            print( bot.objectForKey("name") as! NSString )

                        }
                    }
                }
            }
        }
    }
    
    func identifyRobot( minor:NSNumber ) -> NSMutableDictionary{
        
        var foundBot:NSMutableDictionary = self.bots[0] as! NSMutableDictionary
        
        for bot in self.bots{
            
            let robot = bot as! NSMutableDictionary
            
            let min = (robot.objectForKey("beacon") as! NSString).integerValue
            
            if( min == minor ){
                foundBot = robot
                break
            }
                            
        }
        
        return foundBot
    }
    
    
    func omitRobot( name:NSString ) -> Bool {
        
        var omit:Bool = false
        
        do{
        
            let fileManager = NSFileManager.defaultManager()
        
            let documentsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
        
            let storeURL = documentsDir.URLByAppendingPathComponent("cloudant-sync-datastore")
            
            let path = storeURL.path
        
            let manager = try CDTDatastoreManager(directory: path)
        
            let datastore = try manager.datastoreNamed("playerdata")
            
            let query = [ "name" : name ]
            
            let result = datastore.find(query)
        
            if result.documentIds.count > 0{
                
                result.enumerateObjectsUsingBlock({ (rev, idx, stop) -> Void in
            
                    let playerData = rev.body;
                    
                    let bots = playerData.objectForKey("robots") as! NSMutableArray
            
                    for bot in bots{
                    
                        if bot.objectForKey("name") as! NSString == name {
                        
                            if bot.objectForKey("status") as! NSString == "wanted"{
                                omit = false
                            }else{
                                omit = true
                            }
                        
                            break
                        }
                    }
                })
            }
            
        }catch {
            print("Encountered an error: \(error)")
        }
        
        return omit
    }
    
    //function to easily create alert messages
    func alert(titleInput : String , messageInput : String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}



