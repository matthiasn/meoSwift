//
//  RestApiManager.swift
//  iWasWhere
//
//  Created by mn on 14/07/16.
//  Copyright © 2016 mn. All rights reserved.
//

import Foundation

class RestApiManager {
    let session = URLSession(configuration: URLSessionConfiguration.default)
    var task: URLSessionDataTask!

    func upload (_ address: String, filename: String) {
        let request = NSMutableURLRequest(url: URL(string: address + filename)!)
        request.httpMethod = "POST"
        let iwwFileManager = IwwFileManager()
        let str = iwwFileManager.readFile(filename)
        let data = str.data(using: String.Encoding.utf8)

        task = session.uploadTask(with: request as URLRequest, from: data, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let response = NSString(data: data, encoding:String.Encoding.utf8.rawValue)
                print(response)
                
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "yyyyMMdd-HHmmss-SSS-"
                let newFilename = dayTimePeriodFormatter.string(from: Date()) + filename
                
                if let dir: NSString = NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.documentDirectory, Foundation.FileManager.SearchPathDomainMask.allDomainsMask, true).first as! NSString {
                    let oldPath = dir.appendingPathComponent(filename);
                    let newPath = dir.appendingPathComponent(newFilename);
                
                    let fileManager = Foundation.FileManager.default
                    do { try fileManager.moveItem(atPath: oldPath, toPath: newPath) }
                    catch let error as NSError {print("Could not rename: \(error)")}
                }
            }
        }) 
        task.resume()
    }

    func uploadEntry (_ address: String, entry: String, filename: String) {
        let request = NSMutableURLRequest(url: URL(string: address + filename)!)
        request.httpMethod = "POST"
        let data = entry.data(using: String.Encoding.utf8)
        
        task = session.uploadTask(with: request as URLRequest, from: data, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let response = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print(response)
            }
        }) 
        task.resume()
    }

    func uploadImage (_ address: String, data: Data, filename: String) {
        let request = NSMutableURLRequest(url: URL(string: address + "images/" + filename)!)
        request.httpMethod = "PUT"
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        
        task = session.uploadTask(with: request as URLRequest, from: data, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let response = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print(response)
            }
        }) 
        task.resume()
    }
    
    func uploadAudio (_ address: String, filename: String) {
        let request = NSMutableURLRequest(url: URL(string: address + "audio/" + filename)!)
        request.httpMethod = "PUT"
        request.addValue("audio/m4a", forHTTPHeaderField: "Content-Type")
        
        let iwwFileManager = IwwFileManager()
        let data = iwwFileManager.readBinaryFile(filename)
        
        task = session.uploadTask(with: request as URLRequest, from: data, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let response = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print(response)
            }
        }) 
        task.resume()
    }
}
