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

class GeoEntry: Mappable {
    // MARK: Properties
    var lat: Double?
    var lon: Double?
    var altitude: Double?
    var speed: Double?
    var course: Double?
    var timestamp: CLong?
    var dateTime: String?
    var horizontalAccuracy: Double?
    var verticalAccuracy: Double?
    var device: String = "iPhone"
    
    // MARK: Initialization
    
    init?(lat: Double,
          lon: Double,
          dateTime: NSDate,
          altitude: Double,
          speed: Double,
          course: Double,
          horizontalAccuracy: Double,
          verticalAccuracy: Double) {
        // Initialize stored properties.
        self.lat = lat
        self.lon = lon
        self.altitude = altitude
        self.speed = speed
        self.course = course
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.timestamp = (CLong)(dateTime.timeIntervalSince1970 * 1000)
        self.dateTime = "\(dateTime)"
        
        if lat == 0.0 || lat == 0.0 || timestamp == 0 {
            return nil
        }
    }
    
    init?(location: CLLocation) {
        self.lat = location.coordinate.latitude
        self.lon = location.coordinate.longitude
        self.dateTime = "\(location.timestamp)"
        self.timestamp = (CLong)(location.timestamp.timeIntervalSince1970 * 1000)
        self.altitude = location.altitude
        self.speed = location.speed
        self.course = location.course
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
    }
    
    required init?(_ map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        lat                <- map["latitude"]
        lon                <- map["longitude"]
        altitude           <- map["altitude"]
        speed              <- map["speed"]
        course             <- map["course"]
        timestamp          <- map["timestamp"]
        dateTime           <- map["dateTime"]
        horizontalAccuracy <- map["horizontalAccuracy"]
        verticalAccuracy   <- map["verticalAccuracy"]
        device             <- map["device"]
    }
}

