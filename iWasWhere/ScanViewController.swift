//
//  ScanViewController.swift
//  barcode
//
//  Created by mn on 18/07/16.
//  Copyright © 2016 mn. All rights reserved.
//

import UIKit
import RSBarcodes_Swift
import ObjectMapper

class ScanViewController: RSCodeReaderViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var done = false
        
        self.barcodesHandler = { barcodes in
            for barcode in barcodes {
                if !done {
                    print("uploading: " + barcode.stringValue)
                    let api = RestApiManager()

                    if let dir: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                        let path = dir.stringByAppendingPathComponent("text-entries.json");
                        let data = String(data: NSData(contentsOfFile: path)!, encoding: NSUTF8StringEncoding)
                        if let content = data {
                            let jsonStrings = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                            for jsonString in jsonStrings {
                                print(jsonString)
                                let textEntry = Mapper<TextEntry>().map(jsonString)
                                if let audioFilename = textEntry?.audioFile {
                                    print(audioFilename)
                                    api.uploadAudio(barcode.stringValue, filename: audioFilename)
                                }
                                print("print(textEntry?.imgFile) ScanViewController ")
                                print(textEntry?.imgFile)
                                if let imgFilename = textEntry?.imgFile {
                                    print(imgFilename)
                                    
                                    

                                    let img = UIImage(contentsOfFile: imgFilename)
                                    print(img)
                                    do {
                                        let imgData = try NSData(contentsOfFile: imgFilename, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                                        
                                        
                                        
                                        print("imgData?.length in ScanViewController")
                                        print(imgData.length)
                                    }
                                    catch let error as NSError {print("Could not read: \(error)")}
                                    
                                    //api.uploadAudio(barcode.stringValue, filename: audioFilename)
                                }
                            }
                        }
                    }

                    api.upload(barcode.stringValue, filename: "text-entries.json")
                    api.upload(barcode.stringValue, filename: "visits.json")
                    done = true
                }
                self.dismissViewControllerAnimated(true, completion: {});
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
