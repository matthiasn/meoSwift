//
//  ScanViewController.swift
//  barcode
//
//  Created by mn on 18/07/16.
//  Copyright © 2016 mn. All rights reserved.
//

import UIKit
import RSBarcodes_Swift

class ScanViewController: RSCodeReaderViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var done = false
        
        self.barcodesHandler = { barcodes in
            for barcode in barcodes {
                if !done {
                    print("uploading: " + barcode.stringValue)
                    let api = RestApiManager()
                    api.upload(barcode.stringValue, filename: "text-entries.json")
                    api.upload(barcode.stringValue, filename: "visits.json")
                    api.uploadAudio(barcode.stringValue, filename: "recording.m4a")
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
