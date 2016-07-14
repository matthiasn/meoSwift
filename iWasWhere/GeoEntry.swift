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
    var timestamp: Double?
    var dateTime: String?
    var horizontalAccuracy: Double?
    var verticalAccuracy: Double?
    var device: String = "iPhone"
    var type: String = "geolocation"
    
    // MARK: Initialization
    init?(location: CLLocation) {
        self.lat = location.coordinate.latitude
        self.lon = location.coordinate.longitude
        self.dateTime = "\(location.timestamp)"
        self.timestamp = location.timestamp.timeIntervalSince1970
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
        dateTime           <- map["date_time"]
        horizontalAccuracy <- map["horizontal_accuracy"]
        verticalAccuracy   <- map["vertical_accuracy"]
        device             <- map["device"]
        type               <- map["type"]
    }
}

