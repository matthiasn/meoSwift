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
import MobileCoreServices
import FontAwesome_swift
import AssetsLibrary
import Photos

class ViewController: UIViewController, CLLocationManagerDelegate, AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var camButton: UIButton!
    @IBOutlet weak var logsButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioFilename: String!
    var imgFilename: String!
    var imgIdentifier: String!
    
    let fileManager = FileManager()
    var tempEntry: TextEntry? = nil
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textInput.becomeFirstResponder()
        
        saveButton.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        saveButton.setTitle(String.fontAwesomeIconWithName(.FloppyO), forState: .Normal)
        uploadButton.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        uploadButton.setTitle(String.fontAwesomeIconWithName(.Upload), forState: .Normal)
        recordButton.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        recordButton.setTitle(String.fontAwesomeIconWithName(.Microphone), forState: .Normal)
        camButton.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        camButton.setTitle(String.fontAwesomeIconWithName(.CameraRetro), forState: .Normal)
        logsButton.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        logsButton.setTitle(String.fontAwesomeIconWithName(.FileText), forState: .Normal)
        
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
    
    func imageSaved(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        if let asset = image.imageAsset {
            let fetchOptions: PHFetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
            
            if (fetchResult.firstObject != nil) {
                let lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
                print(lastAsset.localIdentifier)
                print(lastAsset.creationDate)
                let requestOptions = PHImageRequestOptions()
                PHImageManager.defaultManager().requestImageDataForAsset(lastAsset, options: requestOptions, resultHandler: { (data, str, orientation, info) in
                    print("requestImageDataForAsset in VC")
                    let path = info!["PHImageFileURLKey"] as! NSURL
                    let fileName = path.absoluteString.componentsSeparatedByString("/").last
                    
                    let dayTimePeriodFormatter = NSDateFormatter()
                    dayTimePeriodFormatter.dateFormat = "yyyyMMdd_HHmmss"
                    self.imgFilename = dayTimePeriodFormatter.stringFromDate(NSDate()) + "_" + fileName!
                })
                imgIdentifier = lastAsset.localIdentifier
            }
        }
        if error != nil {
            // Report error to user
        }
    }
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let metadata = info[UIImagePickerControllerMediaMetadata] as! [NSObject : AnyObject]
        //let imgData = UIImagePNGRepresentation(image)
        let imgData = UIImageJPEGRepresentation(image, 1.0)
        //imgData?.writeToFile(fileInDocumentsDirectory("image.jpg"), atomically: true)
        
        //UIImageWriteToSavedPhotosAlbum(image, self,
        //                               #selector(ViewController.imageSaved( _:didFinishSavingWithError:contextInfo:)), nil)
        
        ALAssetsLibrary().writeImageDataToSavedPhotosAlbum(imgData, metadata: metadata) { (url, error) in
            if let asset = image.imageAsset {
                let fetchOptions: PHFetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
                
                if (fetchResult.firstObject != nil) {
                    let lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
                    print(lastAsset.localIdentifier)
                    print(lastAsset.creationDate)
                    
                    let requestOptions = PHImageRequestOptions()
                    PHImageManager.defaultManager().requestImageDataForAsset(lastAsset, options: requestOptions, resultHandler: { (data, str, orientation, info) in
                        print("requestImageDataForAsset in VC")
                        let path = info!["PHImageFileURLKey"] as! NSURL
                        let fileName = path.absoluteString.componentsSeparatedByString("/").last
                        
                        let dayTimePeriodFormatter = NSDateFormatter()
                        dayTimePeriodFormatter.dateFormat = "yyyyMMdd_HHmmss"
                        self.imgFilename = dayTimePeriodFormatter.stringFromDate(NSDate()) + "_" + fileName!
                        print(self.imgFilename)
                        print(data?.length)
                    })
                    self.imgIdentifier = lastAsset.localIdentifier
                }
            }
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cam(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.Camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveText(sender: AnyObject) {
        let newEntry = TextEntry(md: textInput.text, submitDateTime: NSDate(), audioFile: audioFilename, imgFile: imgFilename,
                                 imgIdentifier: imgIdentifier)
        let newEntryString = Mapper().toJSONString(newEntry!)
        fileManager.appendLine("text-entries.json", line: newEntryString!)
        tempEntry = newEntry
        textInput.text = ""
        locationManager.requestLocation()
        audioFilename = nil
    }
    
    // from https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        print("finishRecording " + audioFilename)
        recordButton.setTitle(String.fontAwesomeIconWithName(.Microphone), forState: .Normal)
    }
    
    var isRecording = false
    
    // adapted from https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
    func startRecording() {
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            
            let dayTimePeriodFormatter = NSDateFormatter()
            dayTimePeriodFormatter.dateFormat = "yyyyMMdd_HHmmss"
            audioFilename = dayTimePeriodFormatter.stringFromDate(NSDate()) + ".m4a"
            
            let fileWithPath = dir.stringByAppendingPathComponent(audioFilename)
            let audioURL = NSURL(fileURLWithPath: fileWithPath)
            recordButton.setTitle(String.fontAwesomeIconWithName(.Stop), forState: .Normal)
            
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
            } catch {
                finishRecording(success: false)
            }
        }
    }
    
    @IBAction func record(sender: AnyObject) {
        if !isRecording {
            startRecording()
            isRecording = true
            saveButton.enabled = false
            uploadButton.enabled = false
            camButton.enabled = false
            logsButton.enabled = false
        }
        else {
            finishRecording(success: true)
            isRecording = false
            saveButton.enabled = true
            uploadButton.enabled = true
            camButton.enabled = true
            logsButton.enabled = true
        }
    }
    
    @IBAction func upload(sender: AnyObject) {
        textInput.resignFirstResponder()
        let svc = ScanViewController()
        self.presentViewController(svc, animated: true, completion: { () -> Void in
            self.textInput.becomeFirstResponder() })
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

