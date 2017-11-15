//
//  AppDelegate.swift
//  iWasWhere
//
//  Created by mn on 07/04/16.
//  Copyright © 2016 mn. All rights reserved.
//

import UIKit
import CoreLocation
import ObjectMapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    fileprivate var locationManager = CLLocationManager()
    let fileManager = FileManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let types:UIUserNotificationType = ([.alert, .sound, .badge])
        let settings:UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        
        // activate proximity sensor, which automatically makes the screen turn dark when held to ear
        // for notifications on changes, see http://stackoverflow.com/questions/30759711/proximity-sensor-in-swift-from-objective-c
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 1000
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        //locationManager.startUpdatingLocation()
        //locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startMonitoringVisits()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "matthiasn.iWasWhere" in the application's documents Application Support directory.
        let urls = Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {        
        let newEntry = GeoEntry(location: locations.last!)!
        let JSONString = Mapper().toJSONString(newEntry)
        fileManager.appendLine(fileManager.rollingFilename("geo-"), line: JSONString!)
        
        NotificationCenter.defaultCenter().postNotificationName("didUpdateLocations", object:nil, userInfo: ["newEntry":newEntry])
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let newVisit = Visit(visit: visit)
        let visitString = Mapper().toJSONString(newVisit!)
        fileManager.appendLine("visits.json", line: visitString!)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "didVisit"), object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error, terminator: "")
    }

}

