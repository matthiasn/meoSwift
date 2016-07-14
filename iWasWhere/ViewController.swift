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

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var visitTextView: UITextView!
    @IBOutlet weak var textInput: UITextView!

    let myFile = MyFile()
    var tempEntry: TextEntry? = nil
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUI), name:"didUpdateLocations", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUI), name:"didVisit", object: nil)
        locationManager.delegate = self
        loadFiles()
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
    
    @IBAction func saveText(sender: AnyObject) {
        let newEntry = TextEntry(md: textInput.text, submitDateTime: NSDate())
        let newEntryString = Mapper().toJSONString(newEntry!)
        myFile.appendLine("text-entries.json", line: newEntryString!)
        tempEntry = newEntry
        textInput.text = ""
        textInput.resignFirstResponder()
        locationManager.requestLocation()
    }
    
    func loadFiles() {
        //textView.text = myFile.readFile(myFile.rollingFilename("geo-"))
        //textView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count-1, 0))
        
        //visitTextView.text = myFile.readFile("visits.json")
        //visitTextView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count-1, 0))
    }

    @objc func updateUI(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let newEntry = userInfo["newEntry"] as! GeoEntry
        }
        loadFiles()
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (tempEntry != nil) {
            let loc = locations.last!
            
            tempEntry?.latitude = loc.coordinate.latitude
            tempEntry?.longitude = loc.coordinate.longitude
            tempEntry?.horizontalAccuracy = loc.horizontalAccuracy
            tempEntry?.gpsTimestamp = loc.timestamp.timeIntervalSince1970

            let JSONString = Mapper().toJSONString(tempEntry!)
            myFile.appendLine("text-entries.json", line: JSONString!)
            tempEntry = nil
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
 
}

