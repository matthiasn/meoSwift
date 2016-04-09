//
//  ViewController.swift
//  iWasWhere
//
//  Created by mn on 07/04/16.
//  Copyright © 2016 mn. All rights reserved.
//

import UIKit
import CoreLocation
import ObjectMapper

class ViewController: UIViewController {
    
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var tsLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var visitTextView: UITextView!

    let myFile = MyFile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUI), name:"didUpdateLocations", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUI), name:"didVisit", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func someNotification(sender: AnyObject) {
        let notification = UILocalNotification()
        notification.applicationIconBadgeNumber = 1
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.alertBody = "Hey you! Yeah you! Swipe to unlock!"
        notification.alertAction = "be awesome!"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    @IBAction func geoRecord(sender: AnyObject) {
        //locationManager.requestLocation()
        //locationManager.startUpdatingLocation()
        //locationManager.startMonitoringSignificantLocationChanges()
    }

    @objc func updateUI(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let newEntry = userInfo["newEntry"] as! GeoEntry
            latLabel.text = "Lat: \(newEntry.lat!)"
            lonLabel.text = "Lon: \(newEntry.lon!)"
            tsLabel.text = "\(newEntry.dateTime!)"
        }
        textView.text = myFile.readFile(myFile.rollingFilename("geo-"))
        textView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count-1, 0))
        
        visitTextView.text = myFile.readFile("visits.json")
        visitTextView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count-1, 0))
    }
 
}

