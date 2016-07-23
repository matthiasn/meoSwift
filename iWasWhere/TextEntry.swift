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
    var timestamp: Double?
    var gpsTimestamp: Double?
    var dateTime: String?
    var audioFile: String?
    var imgFile: String?
    var imgIdentifier: String?
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
        self.timestamp = submitDateTime.timeIntervalSince1970
        self.dateTime = "\(submitDateTime)"
    }
    
    init?(md: String,
          submitDateTime: NSDate,
          audioFile: String?,
          imgFile: String?,
          imgIdentifier: String?) {
        // Initialize stored properties.
        self.md = md
        self.timestamp = submitDateTime.timeIntervalSince1970
        self.dateTime = "\(submitDateTime)"
        self.audioFile = audioFile
        self.imgFile = imgFile
        self.imgIdentifier = imgIdentifier
    }
    
    required init?(_ map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        latitude           <- map["latitude"]
        md                 <- map["md"]
        longitude          <- map["longitude"]
        dateTime           <- map["date_time"]
        audioFile          <- map["audio_file"]
        imgFile            <- map["img_file"]
        imgIdentifier      <- map["img_identifier"]
        timestamp          <- map["timestamp"]
        gpsTimestamp       <- map["gps_timestamp"]
        horizontalAccuracy <- map["horizontal_accuracy"]
        device             <- map["device"]
        type               <- map["type"]
    }
}

