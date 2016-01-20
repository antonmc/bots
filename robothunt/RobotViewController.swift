//
//  RobotViewController.swift
//  robothunt
//
//  Created by Anton McConville on 2016-01-19.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit



class RobotViewController: UIViewController{
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var codeField: UITextField!
    
    var robotImage:UIImage!
    
    var robotData:NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = self.colorWithHexString("1d3649")
        
        let decodedData = NSData(base64EncodedString: self.robotData.objectForKey("fullBase64") as! String, options: NSDataBase64DecodingOptions(rawValue: 0))
        self.robotImage = UIImage(data: decodedData!)
        self.imageView.image = robotImage
        
        self.title = self.robotData.objectForKey("name")?.uppercaseString
    }
    
    override func viewDidAppear(animated: Bool) {

        let point = imageView.frame.origin.y + 100
        
        codeField.frame = CGRect(x:imageView.frame.origin.x, y: point, width: codeField.frame.size.width, height: codeField.frame.size.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}
