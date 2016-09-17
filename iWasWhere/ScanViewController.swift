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
import Photos

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
                        //let data = String(data: NSData(contentsOfFile: path)!, encoding: NSUTF8StringEncoding)
                        
                        let data = NSData(contentsOfFile: path)
                        
                        if let content = data {
                            let dataString = String(data: content, encoding: NSUTF8StringEncoding)
                            let jsonStrings = dataString!.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                            for jsonString in jsonStrings {
                                print(jsonString)
                                
                                //api.uploadEntry(barcode.stringValue, entry: jsonString, filename: "text-entries.json")
                                
                                let textEntry = Mapper<TextEntry>().map(jsonString)
                                if let audioFilename = textEntry?.audioFile {
                                    print(audioFilename)
                                    api.uploadAudio(barcode.stringValue, filename: audioFilename)
                                }
                                if let imgIdentifier = textEntry?.imgIdentifier {
                                    let imgFilename = textEntry?.imgFile
                                    let fetchResults = PHAsset.fetchAssetsWithLocalIdentifiers([imgIdentifier], options: nil)
                                    if fetchResults.count > 0 {
                                        if let imageAsset = fetchResults.objectAtIndex(0) as? PHAsset {
                                            let requestOptions = PHImageRequestOptions()
                                            requestOptions.deliveryMode = .HighQualityFormat
                                            
                                            PHImageManager.defaultManager().requestImageDataForAsset(imageAsset, options: requestOptions, resultHandler: { (data, str, orientation, info) in
                                                
                                                if let filename = imgFilename {
                                                    api.uploadImage(barcode.stringValue, data: data!, filename: filename)
                                                }
                                                else {
                                                    print(imgFilename, data)
                                                }
                                                
                                                //api.uploadImage(barcode.stringValue, data: data!, filename: imgFilename!)
                                            })
                                        }
                                    }
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
