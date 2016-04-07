//
//  GeoEntry.swift
//  iWasWhere
//
//  Created by mn on 07/04/16.
//  Copyright © 2016 mn. All rights reserved.
//

import UIKit

class GeoEntry {
    // MARK: Properties
    var lat: Float
    var lon: Float
    var timestamp: CLong
    
    // MARK: Initialization
    init?(lat: Float, lon: Float, timestamp: CLong) {
        // Initialize stored properties.
        self.lat = lat
        self.lon = lon
        self.timestamp = timestamp        
        if lat == 0.0 || lat == 0.0 || timestamp == 0 {
            return nil
        }
    }
}

