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

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var tsLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: Properties
    var geoEntries = [GeoEntry]()
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return geoEntries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let geoEntry = geoEntries[indexPath.row]
        cell.textLabel?.text = String(format: "Lat: %.5f Lon: %.5f", geoEntry.lat!, geoEntry.lon!)
        //cell.textLabel?.text = Mapper().toJSONString(geoEntry)
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // from http://szulctomasz.com/ios-9-getting-single-location-update-with-requestlocation/
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        locationManager.delegate = self
        locationManager.distanceFilter = 100
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
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
    
    func writeGeoEntryJSON(geoEntry: GeoEntry) {
        let JSONString = Mapper().toJSONString(geoEntry)
        let file = "\(geoEntry.millis!).json"
        
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            
            let path = dir.stringByAppendingPathComponent(file);
            
            //writing
            do {
                try JSONString!.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {/* error handling here */}
        }
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
            fileHandle?.closeFile()
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
        
        geoEntries += [newEntry]
        tableView.reloadData()
        
        writeGeoEntryJSON(newEntry)
        appendGeoEntryJSON(newEntry)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

}

