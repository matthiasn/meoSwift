//
//  file.swift
//  iWasWhere
//
//  Created by mn on 09/04/16.
//  Copyright © 2016 mn. All rights reserved.
//

import Foundation
import ObjectMapper

class MyFile {

    let fm = NSFileManager.defaultManager()
    let dayTimePeriodFormatter = NSDateFormatter()
    
    func rollingFilename(prefix: String) -> String {
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dayTimePeriodFormatter.stringFromDate(NSDate())
        return "\(prefix)\(dateString).json"
    }
    
    func appendLine(fileName: String, line: String) {
        let withNewline = "\(line)\r\n"
        
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(fileName);
            
            //create file if it doesn't exist
            if !fm.fileExistsAtPath(path) {
                fm.createFileAtPath(path, contents: nil, attributes: nil)
            }
            let fileHandle = NSFileHandle(forUpdatingAtPath: path)
            fileHandle?.seekToEndOfFile()
            fileHandle?.writeData(withNewline.dataUsingEncoding(NSUTF8StringEncoding)!)
            fileHandle?.closeFile()
        }
    }
    
    func readFile(fileName: String) -> String {
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(fileName);
            
            //create file if it doesn't exist
            if !fm.fileExistsAtPath(path) {
                fm.createFileAtPath(path, contents: nil, attributes: nil)
            }
            let fileHandle = NSFileHandle(forUpdatingAtPath: path)
            let fileData = fileHandle?.readDataToEndOfFile()
            fileHandle?.closeFile()
            return NSString(data: fileData!, encoding: NSUTF8StringEncoding) as! String
        }
        return ""
    }

}
