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

class Visit: Mappable {
    // MARK: Properties
    var latitude: Double?
    var longitude: Double?
    var arrivalTimestamp: Double?
    var departureTimestamp: Double?
    var arrivalDate: String?
    var departureDate: String?
    var horizontalAccuracy: Double?
    var device: String = "iPhone"
    var type: String = "visit"
    
    // MARK: Initialization 
    init?(visit: CLVisit) {
        // Initialize stored properties.
        self.latitude = visit.coordinate.latitude
        self.longitude = visit.coordinate.longitude
        self.horizontalAccuracy = visit.horizontalAccuracy
        self.arrivalTimestamp = visit.arrivalDate.timeIntervalSince1970
        self.departureTimestamp = visit.departureDate.timeIntervalSince1970
        self.arrivalDate = "\(visit.arrivalDate)"
        self.departureDate = "\(visit.departureDate)"
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        latitude           <- map["latitude"]
        longitude          <- map["longitude"]
        arrivalDate        <- map["arrival_date"]
        departureDate      <- map["departure_date"]
        arrivalTimestamp   <- map["arrival_timestamp"]
        departureTimestamp <- map["departure_timestamp"]
        horizontalAccuracy <- map["horizontal_accuracy"]
        device             <- map["device"]
        type               <- map["type"]
    }
}

