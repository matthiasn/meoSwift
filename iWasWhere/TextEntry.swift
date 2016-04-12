//
//  GeoEntry.swift
//  iWasWhere
//
//  Created by mn on 07/04/16.
//  Copyright © 2016 mn. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

class TextEntry: Mappable {
    // MARK: Properties
    var md: String?
    var latitude: Double?
    var longitude: Double?
    var timestamp: CLong?
    var gpsTimestamp: CLong?
    var dateTime: String?
    var horizontalAccuracy: Double?
    var device: String = "iPhone"
    var type: String = "text"
    
    // MARK: Initialization 
    init?(md: String,
          lat: Double,
          lon: Double,
          submitDateTime: NSDate,
          horizontalAccuracy: Double) {
        // Initialize stored properties.
        self.md = md
        self.latitude = lat
        self.longitude = lon
        self.horizontalAccuracy = horizontalAccuracy
        self.timestamp = (CLong)(submitDateTime.timeIntervalSince1970 * 1000)
        self.dateTime = "\(submitDateTime)"
    }
    
    init?(md: String,
          submitDateTime: NSDate) {
        // Initialize stored properties.
        self.md = md
        self.timestamp = (CLong)(submitDateTime.timeIntervalSince1970 * 1000)
        self.dateTime = "\(submitDateTime)"
    }
    
    required init?(_ map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        latitude           <- map["latitude"]
        md                 <- map["md"]
        longitude          <- map["longitude"]
        dateTime           <- map["date_time"]
        timestamp          <- map["timestamp"]
        gpsTimestamp       <- map["gps_timestamp"]
        horizontalAccuracy <- map["horizontal_accuracy"]
        device             <- map["device"]
        type               <- map["type"]
    }
}

