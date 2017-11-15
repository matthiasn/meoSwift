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
import MobileCoreServices
import AssetsLibrary
import Photos
import ImagePicker
import BarcodeScanner

class ViewController: UIViewController, CLLocationManagerDelegate, AVAudioRecorderDelegate, UINavigationControllerDelegate, ImagePickerDelegate {
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print(images)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    
    
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var logsButton: UIButton!
    @IBOutlet weak var camRollBtn: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioFilename: String!
    var imgFilename: String!
    var imgIdentifier: String!
    var linkedImgAssets = [PHAsset]()
    
    let iwwFileManager = IwwFileManager()
    var tempEntry: TextEntry? = nil
    fileprivate var locationManager = CLLocationManager()
    
    var imagePickerController: ImagePickerController!
    
    let lightBackground = UIColor(red: 170/255, green: 185/255, blue: 190/255, alpha: 1)
    let lightTextBackground = UIColor(red: 215/255, green: 220/255, blue: 225/255, alpha: 1)
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
        saveButton.setTitle("save", for: [])
        uploadButton.setTitle("upload", for: [])
        recordButton.setTitle("mic", for: [])
        camRollBtn.setTitle("camRoll", for: [])
        logsButton.setTitle("night", for: [])
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
    

    func wrapperDidPress(_ images: [UIImage]) {
    }
    
    // called when done button in image picker is pressed
    func doneButtonDidPress(_ images: [UIImage]) {
        linkedImgAssets = imagePickerController.stack.assets
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func imagePick(_ sender: AnyObject) {
        var configuration = Configuration()
        configuration.doneButtonTitle = "Finish"
        configuration.noImagesTitle = "Sorry! There are no images here!"
        configuration.recordLocation = true
        let imagePicker = ImagePickerController(configuration: configuration)
        imagePickerController = imagePicker
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func geoRecord(_ sender: AnyObject) {
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func getDocumentsURL() -> URL {
        let documentsURL = Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(_ filename: String) -> String {
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
    }
    
    @IBAction func saveText(_ sender: AnyObject) {
        let entryText = textInput.text
        let newEntry = TextEntry(md: entryText!, submitDateTime: Date(), audioFile: audioFilename,
                                 imgFile: imgFilename, imgIdentifier: imgIdentifier)
        let newEntryString = Mapper().toJSONString(newEntry!)
        iwwFileManager.appendLine("text-entries.json", line: newEntryString!)
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
                self.iwwFileManager.appendLine("text-entries.json", line: linkedEntryString!)
            })
        }
        textInput.text = ""
        audioFilename = nil
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
        if let dir: NSString = NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.documentDirectory, Foundation.FileManager.SearchPathDomainMask.allDomainsMask, true).first as NSString? {
            
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
            camRollBtn.isEnabled = false
            logsButton.isEnabled = false
        }
        else {
            finishRecording(success: true)
            isRecording = false
            saveButton.isEnabled = true
            uploadButton.isEnabled = true
            camRollBtn.isEnabled = true
            logsButton.isEnabled = true
        }
    }
    
    @IBAction func upload(_ sender: AnyObject) {
        textInput.resignFirstResponder()
        
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        
        present(controller, animated: true, completion: nil)
    
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
            iwwFileManager.appendLine("text-entries.json", line: JSONString!)
            tempEntry = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error, terminator: "")
    }
    
}

extension ViewController: BarcodeScannerCodeDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        print("Barcode Data: \(code)")
        
        let api = RestApiManager()
        
//        if let dir: NSString = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.picturesDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first as! NSString) {
//            let path = dir.appendingPathComponent("text-entries.json");
//            let data = NSData(contentsOfFile: path)
//
//            if let content = data {
//                let dataString = String(data: content as Data, encoding: String.Encoding.utf8)
//                let jsonStrings =
//                    dataString?.components(separatedBy: NSCharacterSet.newlines)
//                for jsonString in jsonStrings! {
//                    print(jsonString)
//
//                    let textEntry = Mapper<TextEntry>().map(jsonString)
//                    if let audioFilename = textEntry?.audioFile {
//                        print(audioFilename)
//                        api.uploadAudio(code, filename: audioFilename)
//                    }
//                    if let imgIdentifier = textEntry?.imgIdentifier {
//                        let imgFilename = textEntry?.imgFile
//                        let fetchResults = PHAsset.fetchAssetsWithLocalIdentifiers([imgIdentifier], options: nil)
//                        if fetchResults.count > 0 {
//                            if let imageAsset = fetchResults.objectAtIndex(0) as? PHAsset {
//                                let requestOptions = PHImageRequestOptions()
//                                requestOptions.deliveryMode = .highQualityFormat
//
//                                PHImageManager.defaultManager().requestImageDataForAsset(imageAsset, options: requestOptions, resultHandler: { (data, str, orientation, info) in
//
//                                    if let filename = imgFilename {
//                                        api.uploadImage(barcode.stringValue, data: data!, filename: filename)
//                                    }
//                                    else {
//                                        print(imgFilename, data)
//                                    }
//                                })
//                            }
//                        }
//                    }
//                }
//            }
//        }
        
        api.upload(code, filename: "text-entries.json")
        api.upload(code, filename: "visits.json")
        
        let delayTime = DispatchTime.now() + Double(Int64(6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            controller.resetWithError()
        }
    }
}

extension ViewController: BarcodeScannerErrorDelegate {
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: BarcodeScannerDismissalDelegate {
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
