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

    // from http://szulctomasz.com/ios-9-getting-single-location-update-with-requestlocation/
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        //locationManager.distanceFilter = 100
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        //locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func geoRecord(sender: AnyObject) {
        //locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        //locationManager.startMonitoringSignificantLocationChanges()
    }

    func appendGeoEntryJSON(geoEntry: GeoEntry) {
        let JSONString = Mapper().toJSONString(geoEntry)
        let withNewline = "\(JSONString!)\r\n"
        let fm = NSFileManager.defaultManager()
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dayTimePeriodFormatter.stringFromDate(geoEntry.timestamp!)
        
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            
            let path = dir.stringByAppendingPathComponent("\(dateString).json");
            
            //create file if it doesn't exist
            if !fm.fileExistsAtPath(path) {
                fm.createFileAtPath(path, contents: nil, attributes: nil)
            }
            let fileHandle = NSFileHandle(forUpdatingAtPath: path)
            fileHandle?.seekToEndOfFile()
            fileHandle?.writeData(withNewline.dataUsingEncoding(NSUTF8StringEncoding)!)
            fileHandle?.seekToFileOffset(0)
            let fileData = fileHandle?.readDataToEndOfFile()
            fileHandle?.closeFile()
            textView.text = NSString(data: fileData!, encoding: NSUTF8StringEncoding) as! String
            textView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count-1, 0))
        }
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
        
        appendGeoEntryJSON(newEntry)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

}

