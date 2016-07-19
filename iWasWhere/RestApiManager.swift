//
//  RestApiManager.swift
//  iWasWhere
//
//  Created by mn on 14/07/16.
//  Copyright © 2016 mn. All rights reserved.
//

import Foundation

class RestApiManager {
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var task: NSURLSessionDataTask!

    func upload (address: String, filename: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: address + filename)!)
        request.HTTPMethod = "POST"
        let myFile = MyFile()
        let str = myFile.readFile(filename)
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)

        task = session.uploadTaskWithRequest(request, fromData: data) { (data, response, error) -> Void in
            if let data = data {
                let response = NSString(data: data, encoding: NSUTF8StringEncoding)
                print(response)
                
                let dayTimePeriodFormatter = NSDateFormatter()
                dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSS-"
                let newFilename = dayTimePeriodFormatter.stringFromDate(NSDate()) + filename
                print(newFilename)
                
                if let dir: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                    let oldPath = dir.stringByAppendingPathComponent(filename);
                    let newPath = dir.stringByAppendingPathComponent(newFilename);
                
                    print(oldPath)
                    print(newPath)
                    
                    let fileManager = NSFileManager.defaultManager()
                    do { try fileManager.moveItemAtPath(oldPath, toPath: newPath) }
                    catch let error as NSError {print("Could not rename: \(error)")}
                }
                
                //let fileManager = NSFileManager.defaultManager()
                //do { try fileManager.moveItemAtPath(filename, toPath: newFilename) }
                //catch let error as NSError {print("Could not rename: \(error)")}
            }
        }
        task.resume()
    }
}