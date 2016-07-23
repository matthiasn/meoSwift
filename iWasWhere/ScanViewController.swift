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
                                    
                                    let fetchResults = PHAsset.fetchAssetsWithLocalIdentifiers([imgFilename], options: nil)
                                    print(fetchResults)

                                    if fetchResults.count > 0 {
                                        if let imageAsset = fetchResults.objectAtIndex(0) as? PHAsset {
                                            let requestOptions = PHImageRequestOptions()
                                            requestOptions.deliveryMode = .HighQualityFormat

                                            PHImageManager.defaultManager().requestImageDataForAsset(imageAsset, options: requestOptions, resultHandler: { (data, str, orientation, info) in
                                                print("requestImageDataForAsset")
                                                print(data?.length)
                                                api.uploadImage(barcode.stringValue, data: data!, filename: "image3.jpg")
                                            })
                                            
                                            PHImageManager.defaultManager().requestImageForAsset(imageAsset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: requestOptions, resultHandler: { (image, info) -> Void in
                                                let data = UIImageJPEGRepresentation(image!, 1.0)
                                                print("UIImageJPEGRepresentation(image!, 1.0)")
                                                print(data!.length)
                                                print(image)
                                                print(image?.imageOrientation)
                                                //completion(image: image)
                                            })
                                        } else {
                                            //completion(image: nil)
                                        }
                                    } else {
                                        //completion(image: nil)
                                    }

//                                    let img = UIImage(contentsOfFile: imgFilename)
//                                    print(img)
//                                    do {
//                                        let imgData = try NSData(contentsOfFile: imgFilename, options: NSDataReadingOptions.DataReadingMappedIfSafe)
//                                        print("imgData?.length in ScanViewController")
//                                        print(imgData.length)
//                                    }
//                                    catch let error as NSError {print("Could not read: \(error)")}
                                    
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
