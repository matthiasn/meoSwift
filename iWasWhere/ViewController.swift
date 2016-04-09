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
    
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var tsLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    private var locationManager = CLLocationManager()
    let myFile = MyFile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.distanceFilter = 100
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringVisits()
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func geoRecord(sender: AnyObject) {
        //locationManager.requestLocation()
        //locationManager.startUpdatingLocation()
        //locationManager.startMonitoringSignificantLocationChanges()
        
        let notification = UILocalNotification()
        notification.applicationIconBadgeNumber = 1
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.alertBody = "Hey you! Yeah you! Swipe to unlock!"
        notification.alertAction = "be awesome!"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!

        let millis = (CLong)(newLocation.timestamp.timeIntervalSince1970 * 1000)
        
        let newEntry = GeoEntry(lat: newLocation.coordinate.latitude,
                                lon: newLocation.coordinate.longitude,
                                millis: millis,
                                timestamp: newLocation.timestamp,
                                altitude: newLocation.altitude,
                                speed: newLocation.speed,
                                course: newLocation.course,
                                horizontalAccuracy: newLocation.horizontalAccuracy,
                                verticalAccuracy: newLocation.verticalAccuracy)!
        
        latLabel.text = "Lat: \(newEntry.lat!)"
        lonLabel.text = "Lon: \(newEntry.lon!)"
        tsLabel.text = "\(newLocation.timestamp)"
        let JSONString = Mapper().toJSONString(newEntry)

        myFile.appendLine(JSONString!)
        
        textView.text = myFile.readFile()
        textView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count-1, 0))
    }
    
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        print("Visit: \(visit)")
        myFile.appendLine("Visit \(visit.arrivalDate) to \(visit.departureDate) \(visit.coordinate.latitude) \(visit.coordinate.latitude) \(visit.horizontalAccuracy)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

}

