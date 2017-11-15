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
import AssetsLibrary
import Photos
import ImagePicker

class ViewController: UIViewController, CLLocationManagerDelegate, AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerDelegate {
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    
    
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var imgView: UIImageView!    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var camButton: UIButton!
    @IBOutlet weak var logsButton: UIButton!
    @IBOutlet weak var camRollBtn: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioFilename: String!
    var imgFilename: String!
    var imgIdentifier: String!
    var linkedImgAssets = [PHAsset]()
    
    let fileManager = FileManager()
    var tempEntry: TextEntry? = nil
    fileprivate var locationManager = CLLocationManager()
    
    var imagePickerController2: ImagePickerController!
    
    let lightBackground = UIColor(red: 190/255, green: 205/255, blue: 210/255, alpha: 1)
    let lightTextBackground = UIColor(red: 225/255, green: 230/255, blue: 235/255, alpha: 1)
    let darkBackground = UIColor(red: 45/255, green: 62/255, blue: 80/255, alpha: 1)
    let darkTextBackground = UIColor(red: 140/255, green: 155/255, blue: 160/255, alpha: 1)
    
    var nightMode = false
    
    @IBAction func toggleNightMode(_ sender: AnyObject) {
        nightMode = !nightMode
        if nightMode {
            textInput.backgroundColor = darkTextBackground
            self.view.backgroundColor = darkBackground
            textInput.keyboardAppearance = .dark
        } else {
            textInput.backgroundColor = lightTextBackground
            self.view.backgroundColor = lightBackground
            textInput.keyboardAppearance = .light
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        textInput.becomeFirstResponder()

        textInput.backgroundColor = lightTextBackground
        self.view.backgroundColor = lightBackground
        
        imgView.contentMode = .scaleAspectFit
        
        saveButton.setTitle("save", for: [])
        uploadButton.setTitle("upload", for: [])
        recordButton.setTitle("mic", for: [])
        camRollBtn.setTitle("camRoll", for: [])
        logsButton.setTitle("night", for: [])
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name:NSNotification.Name(rawValue: "didUpdateLocations"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name:NSNotification.Name(rawValue: "didVisit"), object: nil)
        locationManager.delegate = self
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                DispatchQueue.main.async {
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
    
    func someNotification(_ sender: AnyObject) {
        let notification = UILocalNotification()
        notification.applicationIconBadgeNumber = 1
        notification.fireDate = Date(timeIntervalSinceNow: 5)
        notification.alertBody = "Hey you! Yeah you! Swipe to unlock!"
        notification.alertAction = "be awesome!"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func wrapperDidPress(_ images: [UIImage]) {
    }
    
    // called when done button in image picker is pressed
    func doneButtonDidPress(_ images: [UIImage]) {
        linkedImgAssets = imagePickerController2.stack.assets
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress() {
    }
    
    @IBAction func imagePick(_ sender: AnyObject) {
        imagePickerController2 = ImagePickerController()
        imagePickerController2.imageLimit = 50
        imagePickerController2.delegate = self
        
        present(imagePickerController2, animated: true, completion: nil)
    }
    
    @IBAction func geoRecord(_ sender: AnyObject) {
        //locationManager.requestLocation()
        //locationManager.startUpdatingLocation()
        //locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSErrorPointer?, contextInfo:UnsafeRawPointer) {
        if let asset = image.imageAsset {
            let fetchOptions: PHFetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
            
            if (fetchResult.firstObject != nil) {
                let lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
                print(lastAsset.localIdentifier)
                print(lastAsset.creationDate)
                let requestOptions = PHImageRequestOptions()
                PHImageManager.default().requestImageData(for: lastAsset, options: requestOptions, resultHandler: { (data, str, orientation, info) in
                    print("requestImageDataForAsset in VC")
                    let path = info!["PHImageFileURLKey"] as! URL
                    let fileName = path.absoluteString.components(separatedBy: "/").last
                    
                    let dayTimePeriodFormatter = DateFormatter()
                    dayTimePeriodFormatter.dateFormat = "yyyyMMdd_HHmmss"
                    self.imgFilename = dayTimePeriodFormatter.string(from: Date()) + "_" + fileName!
                })
                imgIdentifier = lastAsset.localIdentifier
            }
        }
        if error != nil {
            // Report error to user
        }
    }
    
    func getDocumentsURL() -> URL {
        let documentsURL = Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(_ filename: String) -> String {
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage

        imgView.image = image
        
        let metadata = info[UIImagePickerControllerMediaMetadata] as! [AnyHashable: Any]
        //let imgData = UIImagePNGRepresentation(image)
        let imgData = UIImageJPEGRepresentation(image, 0.5)
        //imgData?.writeToFile(fileInDocumentsDirectory("image.jpg"), atomically: true)
        
        //UIImageWriteToSavedPhotosAlbum(image, self,
        //                               #selector(ViewController.imageSaved( _:didFinishSavingWithError:contextInfo:)), nil)
        
        ALAssetsLibrary().writeImageData(toSavedPhotosAlbum: imgData, metadata: metadata) { (url, error) in
            if let asset = image.imageAsset {
                let fetchOptions: PHFetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                
                if (fetchResult.firstObject != nil) {
                    let lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
                    print(lastAsset.localIdentifier)
                    print(lastAsset.creationDate)
                    
                    let requestOptions = PHImageRequestOptions()
                    PHImageManager.default().requestImageData(for: lastAsset, options: requestOptions, resultHandler: { (data, str, orientation, info) in
                        print("requestImageDataForAsset in VC")
                        let path = info!["PHImageFileURLKey"] as! URL
                        let fileName = path.absoluteString.components(separatedBy: "/").last
                        
                        let dayTimePeriodFormatter = DateFormatter()
                        dayTimePeriodFormatter.dateFormat = "yyyyMMdd_HHmmss"
                        self.imgFilename = dayTimePeriodFormatter.string(from: Date()) + "_" + fileName!
                        print(self.imgFilename)
                        print(data?.count)
                    })
                    self.imgIdentifier = lastAsset.localIdentifier
                }
            }
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cam(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.off
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveText(_ sender: AnyObject) {
        let entryText = textInput.text
        let newEntry = TextEntry(md: entryText!, submitDateTime: Date(), audioFile: audioFilename,
                                 imgFile: imgFilename, imgIdentifier: imgIdentifier)
        let newEntryString = Mapper().toJSONString(newEntry!)
        fileManager.appendLine("text-entries.json", line: newEntryString!)
        tempEntry = newEntry
        locationManager.requestLocation()
        
        // create linked entry for each asset in linkedImgAssets
        for asset in linkedImgAssets {
            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateFormat = "yyyyMMdd_HHmmss_SSS"
            
            let requestOptions = PHImageRequestOptions()
            PHImageManager.default().requestImageData(for: asset, options: requestOptions, resultHandler: { (data, str, orientation, info) in
                let path = info!["PHImageFileURLKey"] as! URL
                let fileName = path.absoluteString.components(separatedBy: "/").last
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "yyyyMMdd_HHmmss_SSS"
                
                let linkedEntry = TextEntry(
                    md: entryText! + " (from linked entry)",
                    submitDateTime: asset.creationDate!,
                    audioFile: nil,
                    imgFile: dayTimePeriodFormatter.string(from: (asset.creationDate)!) + "_" + fileName!,
                    imgIdentifier: asset.localIdentifier)
                linkedEntry?.horizontalAccuracy = asset.location?.horizontalAccuracy
                linkedEntry?.latitude = asset.location?.coordinate.latitude
                linkedEntry?.longitude = asset.location?.coordinate.longitude
                linkedEntry?.linkedTimestamp = newEntry?.timestamp
                
                let linkedEntryString = Mapper().toJSONString(linkedEntry!)
                self.fileManager.appendLine("text-entries.json", line: linkedEntryString!)
            })
        }
        textInput.text = ""
        audioFilename = nil
        imgView.image = nil
        imgFilename = nil
        imgIdentifier = nil
        linkedImgAssets = [PHAsset]()
    }
    
    // from https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        print("finishRecording " + audioFilename)
        recordButton.setTitle("record", for: [])
    }
    
    var isRecording = false
    
    // adapted from https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
    func startRecording() {
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.documentDirectory, Foundation.FileManager.SearchPathDomainMask.allDomainsMask, true).first as! NSString {
            
            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateFormat = "yyyyMMdd_HHmmss"
            audioFilename = dayTimePeriodFormatter.string(from: Date()) + ".m4a"
            
            let fileWithPath = dir.appendingPathComponent(audioFilename)
            let audioURL = URL(fileURLWithPath: fileWithPath)
            recordButton.setTitle("stop", for: [])
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1 as NSNumber,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ] as [String : Any]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
            } catch {
                finishRecording(success: false)
            }
        }
    }
    
    @IBAction func record(_ sender: AnyObject) {
        if !isRecording {
            startRecording()
            isRecording = true
            saveButton.isEnabled = false
            uploadButton.isEnabled = false
            camButton.isEnabled = false
            camRollBtn.isEnabled = false
            logsButton.isEnabled = false
        }
        else {
            finishRecording(success: true)
            isRecording = false
            saveButton.isEnabled = true
            uploadButton.isEnabled = true
            camButton.isEnabled = true
            camRollBtn.isEnabled = true
            logsButton.isEnabled = true
        }
    }
    
    @IBAction func upload(_ sender: AnyObject) {
        textInput.resignFirstResponder()
//        let svc = ScanViewController()
//        self.presentViewController(svc, animated: true, completion: { () -> Void in
//            self.textInput.becomeFirstResponder() })
    }
    
    @objc func updateUI(_ notification: Notification) {
        if let userInfo = notification.userInfo {
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error, terminator: "")
    }
    
}

