//
//  GeoEntry.swift
//  iWasWhere
//
//  Created by mn on 07/04/16.
//  Copyright © 2016 mn. All rights reserved.
//

import UIKit
import ObjectMapper

struct GeoEntry: Mappable {
    // MARK: Properties
    var lat: Double?
    var lon: Double?
    var altitude: Double?
    var speed: Double?
    var course: Double?
    var timestamp: CLong?
    var horizontalAccuracy: Double?
    var verticalAccuracy: Double?
    
    // MARK: Initialization
    
    init?(lat: Double,
          lon: Double,
          timestamp: CLong,
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
        
        self.timestamp = timestamp
        if lat == 0.0 || lat == 0.0 || timestamp == 0 {
            return nil
        }
    }
    
    init?(_ map: Map) {

    }
    
    // Mappable
    mutating func mapping(map: Map) {
        lat                <- map["lat"]
        lon                <- map["lon"]
        altitude           <- map["altitude"]
        speed              <- map["speed"]
        course             <- map["course"]
        timestamp          <- map["timestamp"]
        horizontalAccuracy <- map["horizontalAccuracy"]
        verticalAccuracy   <- map["verticalAccuracy"]
    }
    
}

