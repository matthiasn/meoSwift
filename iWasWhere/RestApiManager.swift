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
    let request = NSMutableURLRequest(URL: NSURL(string: "http://10.0.1.3:3001/upload/text-entries.json")!)
    var task: NSURLSessionDataTask!

    func upload () {
        request.HTTPMethod = "POST"
        let myFile = MyFile()
        let str = myFile.readFile("text-entries.json")
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)

        task = session.uploadTaskWithRequest(request, fromData: data) { (data, response, error) -> Void in
            if let data = data {
                let response = NSString(data: data, encoding: NSUTF8StringEncoding)
                print(response)
            }
        }
        task.resume()
    }
}