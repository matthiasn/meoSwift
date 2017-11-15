//
//  file.swift
//  iWasWhere
//
//  Created by mn on 09/04/16.
//  Copyright © 2016 mn. All rights reserved.
//

import Foundation
import ObjectMapper

class FileManager {

    let fm = Foundation.FileManager.default
    let dayTimePeriodFormatter = DateFormatter()
    
    func rollingFilename(_ prefix: String) -> String {
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dayTimePeriodFormatter.string(from: Date())
        return "\(prefix)\(dateString).json"
    }
    
    func appendLine(_ fileName: String, line: String) {
        let withNewline = "\(line)\r\n"
        
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.documentDirectory, Foundation.FileManager.SearchPathDomainMask.allDomainsMask, true).first as! NSString {
            let path = dir.appendingPathComponent(fileName);
            
            //create file if it doesn't exist
            if !fm.fileExists(atPath: path) {
                fm.createFile(atPath: path, contents: nil, attributes: nil)
            }
            let fileHandle = FileHandle(forUpdatingAtPath: path)
            fileHandle?.seekToEndOfFile()
            fileHandle?.write(withNewline.data(using: String.Encoding.utf8)!)
            fileHandle?.closeFile()
        }
    }
    
    func readBinaryFile(_ fileName: String) -> Data? {
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.documentDirectory, Foundation.FileManager.SearchPathDomainMask.allDomainsMask, true).first as! NSString {
            let path = dir.appendingPathComponent(fileName);
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            return data
        }
        return Data()
    }
    
    func readFile(_ fileName: String) -> String {
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.documentDirectory, Foundation.FileManager.SearchPathDomainMask.allDomainsMask, true).first as! NSString {
            let path = dir.appendingPathComponent(fileName)
            
            //create file if it doesn't exist
            if !fm.fileExists(atPath: path) {
                fm.createFile(atPath: path, contents: nil, attributes: nil)
            }
            let fileHandle = FileHandle(forUpdatingAtPath: path)
            let fileData = fileHandle?.readDataToEndOfFile()
            fileHandle?.closeFile()
            return NSString(data: fileData!, encoding: String.Encoding.utf8.rawValue) as! String
        }
        return ""
    }

}
