//
//  ViewController.swift
//  iWasWhere
//
//  Created by mn on 07/04/16.
//  Copyright © 2016 mn. All rights reserved.
//

import UIKit
import CoreLocation
import ObjectMapper
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var textInput: UITextView!
    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioFilename: String!

    let fileManager = FileManager()
    var tempEntry: TextEntry? = nil
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUI), name:"didUpdateLocations", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateUI), name:"didVisit", object: nil)
        locationManager.delegate = self
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        // self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func someNotification(sender: AnyObject) {
        let notification = UILocalNotification()
        notification.applicationIconBadgeNumber = 1
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.alertBody = "Hey you! Yeah you! Swipe to unlock!"
        notification.alertAction = "be awesome!"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    @IBAction func geoRecord(sender: AnyObject) {
        //locationManager.requestLocation()
        //locationManager.startUpdatingLocation()
        //locationManager.startMonitoringSignificantLocationChanges()
    }
    
    @IBAction func saveText(sender: AnyObject) {
        let newEntry = TextEntry(md: textInput.text, submitDateTime: NSDate(), media: audioFilename)
        let newEntryString = Mapper().toJSONString(newEntry!)
        fileManager.appendLine("text-entries.json", line: newEntryString!)
        tempEntry = newEntry
        textInput.text = ""
        textInput.resignFirstResponder()
        locationManager.requestLocation()

        // audio file name should be reset, just keeping it to initiate the upload without parsing the JSON
        //audioFilename = nil
    }
    
    // from https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        print("finishRecording " + audioFilename)
        //print("finishRecording" + audioFilename)
        
        if success {
            //recordButton.setTitle("Tap to Re-record", forState: .Normal)
        } else {
            //recordButton.setTitle("Tap to Record", forState: .Normal)
            // recording failed :(
        }
    }
    
    // adapted from https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
    func startRecording() {
    
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            
            let dayTimePeriodFormatter = NSDateFormatter()
            dayTimePeriodFormatter.dateFormat = "yyyyMMdd_HHmmss"

//            audioFilename = dayTimePeriodFormatter.stringFromDate(NSDate()) + ".m4a"
            audioFilename = "recording.m4a"
            
            let fileWithPath = dir.stringByAppendingPathComponent(audioFilename)
            let audioURL = NSURL(fileURLWithPath: fileWithPath)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1 as NSNumber,
                AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                //recordButton.setTitle("Tap to Stop", forState: .Normal)
            } catch {
                finishRecording(success: false)
            }
        }
        
    }
    
    @IBAction func record(sender: AnyObject) {
        startRecording()
    }
    
    @IBAction func stop(sender: AnyObject) {
        finishRecording(success: true)
    }
    
    @IBAction func upload(sender: AnyObject) {
        let svc = ScanViewController()
        self.presentViewController(svc, animated: true, completion: nil)
    }

    @objc func updateUI(notification: NSNotification) {
        if let userInfo = notification.userInfo {
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (tempEntry != nil) {
            let loc = locations.last!
            
            tempEntry?.latitude = loc.coordinate.latitude
            tempEntry?.longitude = loc.coordinate.longitude
            tempEntry?.horizontalAccuracy = loc.horizontalAccuracy
            tempEntry?.gpsTimestamp = loc.timestamp.timeIntervalSince1970

            let JSONString = Mapper().toJSONString(tempEntry!)
            fileManager.appendLine("text-entries.json", line: JSONString!)
            tempEntry = nil
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error, terminator: "")
    }
 
}

