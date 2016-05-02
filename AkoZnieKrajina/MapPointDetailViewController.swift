//
//  MapPointDetailViewController.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 22/01/16.
//  Copyright © 2016 Peter Krajcir. All rights reserved.
//

import UIKit
import AVFoundation

import CoreData

class MapPointDetailViewController: UIViewController, NSFetchedResultsControllerDelegate, AVAudioPlayerDelegate {

    var mapPoint: MapPoint?
    
// The picture from the location where the sound was recorded
    @IBOutlet weak var imageView: UIImageView!
    
// The title of the sound
    @IBOutlet weak var titleLabel: UILabel!
    
// The address where the sound was recorded
    @IBOutlet weak var addressLabel: UILabel!
    
// Time information of the current playing item
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!

// Enable for Stream Switch - The User can stream the Sound by pressing the Play button only when this switch is on
    @IBOutlet weak var enableForStreamSwitch: UISwitch!
    
// Sound flow control
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
// Download button and progress
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
// Information for the user about available actions
    @IBOutlet weak var infoLabel: UILabel!

// We use Apple's AVFoundation framework, specifically AVPlayer for streaming/playing locally stored mp3 file
    var avPlayer: AVPlayer!
    var avPlayerItem: AVPlayerItem!
    
// We use time observer to update current time of playing sound
// It's recommended way to track this information (in opposite of using the local timer)
    var timeObserver: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidden = true
        
        fetchedResultsController.delegate = self

// Let's fetch the stored data from CoreData Where Id is equal to mapPoint.id
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        
// Let's test if we found a match
        for pin in fetchedResultsController.fetchedObjects! {
            if let pin = pin as? Pin {
                print("found in download db")
                print("id: \(pin.id), title: \(pin.title), sound filename: \(pin.filename)")
                
// The Pin is already downloaded in the phone, let's save the filename of the downloaded sound to the main object - mapPoint
                mapPoint?.filename = pin.filename
            }
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Pin.Keys.EntityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Pin.Keys.Longitude, ascending: true)]
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Pin.Keys.Id, ascending: true)]
        print("looking for id \(self.mapPoint!.id)")
// We use predicate to look only for specific pin with specific id
        fetchRequest.predicate = NSPredicate(format: "id == %d", self.mapPoint!.id);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        print("controllerDidChangeContent called from MapPointDetail")
    }
    
// Helper function that tells us if this sound is downloaded or not
// The function checks it by comparing the number of objects in fetched controller
    func isDownloaded() -> Bool {
        if fetchedResultsController.fetchedObjects?.count == 0 {
            return false
        } else {
            return true
        }
    }
    
// The function changes GUI for streaming option
    func updatePlayPauseButtonsForStream() {
        downloadButton.enabled = true
        enableForStreamSwitch.enabled = true
        activityIndicator.hidden = true
        if enableForStreamSwitch.on {
            playButton.enabled = true
            pauseButton.enabled = true
            print("stream enabled with switch")
        } else {
            playButton.enabled = false
            pauseButton.enabled = false
            print("stream disabled with switch")
        }
    }

// The function changes GUI for downloading option
    func updatePlayPauseButtonsForDownload() {
        enableForStreamSwitch.setOn(false, animated: false)
        enableForStreamSwitch.enabled = false
        downloadButton.enabled = false
        playButton.enabled = true
        pauseButton.enabled = true
        activityIndicator.hidden = true
        print("sound is downloaded, disabling stream switch and download button")
    }
    
    @IBAction func enableForStream(sender: AnyObject) {
        updatePlayPauseButtonsForStream()
    }
    
    @IBAction func streamSound(sender: AnyObject) {
        if avPlayer != nil {
            avPlayer.play()
        } else {
            let targetUrl: NSURL?
            
            if isDownloaded() {
// we play local file stored in soundPath
                let currentPath = DataClient.sharedInstance.pathForIdentifier(mapPoint!.filename!)
// Different init function for NSUrl when we have a local file
                targetUrl = NSURL(fileURLWithPath: currentPath)
            } else {
                targetUrl = NSURL(string: mapPoint!.soundUrl)
            }

            if let soundUrl = targetUrl {

                avPlayerItem = AVPlayerItem(URL: soundUrl)
                
                avPlayer = AVPlayer(playerItem: avPlayerItem)
                
                avPlayer.volume = 1.0
                avPlayer.rate = 1.0
                avPlayer.play()
                
                let duration = avPlayer.currentItem?.asset.duration
// The item's duration is in CMTime and we need it in seconds
                let durationInSeconds = CMTimeGetSeconds(duration!)
                print("Duration is \(durationInSeconds)")
                
                if (durationInSeconds == 0.0) {
                    let alert = UIAlertController(title: "Could not stream. Internet appears to be down.", message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let interval = CMTimeMakeWithSeconds(1.0, 1)
                    // Time observer of AVPlayer, used for constant updates of GUI about the elapsed time of the sound
                    // The function outputCurrentTime is called every second (as set in the variable interval)
                    timeObserver = avPlayer.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue(), usingBlock: outputCurrentTime)
                    currentTimeSlider.maximumValue = Float(durationInSeconds)
                }
            }
        }
    }
    
// Called by the time observer of AVPlayer every second
// Updates GUI about the elapsed time of the sound
    func outputCurrentTime(time: CMTime) {
        let currentSeconds = CMTimeGetSeconds((avPlayer.currentItem?.currentTime())!)
        
        let components = NSDateComponents()
        components.second = Int(currentSeconds)
        
        currentTimeSlider.value = Float(currentSeconds)
        
        let calendar = NSCalendar.currentCalendar()
        let date = calendar.dateFromComponents(components)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "mm:ss"
        let convertedDate = formatter.stringFromDate(date!)
        currentTimeLabel.text = convertedDate
    }
    
// Pause button has been pressed
    @IBAction func streamPause(sender: AnyObject) {
        if avPlayer.rate != 0 && avPlayer.error == nil {
            avPlayer.pause()
        }
    }
    
// Disables all the action buttons in GUI
// Called when we are in the process of downloading the sound so user can call multiple actions
    func disableAllButtons() {
        enableForStreamSwitch.enabled = false
        downloadButton.enabled = false
        playButton.enabled = false
        pauseButton.enabled = false
    }
    
// The user pressed Download button
    @IBAction func downloadSound(sender: AnyObject) {
        if let soundUrl = mapPoint?.soundUrl {
            
// We disable all the buttons and show activity indicator to let the user know that the file is downloading
            disableAllButtons()
            downloadButton.hidden = true
            activityIndicator.hidden = false
            
// Download the sound - function is located in DataClient library
            DataClient.sharedInstance.downloadSound(soundUrl) { (targetFilename, errorString) in

// Once the backend call is over (either success or fail) we enable back the buttons
                dispatch_async(dispatch_get_main_queue()) {
                    self.downloadButton.hidden = false
                    self.activityIndicator.hidden = true
                }
                
                if let errorString = errorString {
                    print(errorString)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = UIAlertController(title: errorString, message: nil, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.updatePlayPauseButtonsForStream()
                    }
                } else {
                    
// When the sound was successfully downloaded into the phone's library, we store it using CoreData and it's available any time for the user
                    self.mapPoint?.filename = targetFilename
                    let pin = Pin(mapPoint: self.mapPoint!, context: self.sharedContext)

// We store the object using CoreData
                    self.sharedContext.insertObject(pin)
                    CoreDataStackManager.sharedInstance().saveContext()

// GUI updates
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = UIAlertController(title: "The sound was successfully downloaded.", message: nil, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.updatePlayPauseButtonsForDownload()
                        self.infoLabel.text = "The sound was placed in your library. You can listen to it. The stream option is disabled."
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        currentTimeLabel.text = ""
        self.title = "Sound"
        
        if isDownloaded() {
            updatePlayPauseButtonsForDownload()
            infoLabel.text = "The sound is already downloaded in your library. You can listen to it. The stream option is disabled."
        } else {
            updatePlayPauseButtonsForStream()
            infoLabel.text = "You can enable stream to listen to the sound directly or you can download it to your library."
        }
        
// We download the image of the MapPoint and display it
        if let imageUrl = mapPoint?.imageUrl {
            if imageUrl != "" {
                let url = NSURL(string: imageUrl)
                let request = NSURLRequest(URL: url!)
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request) { data, response, error in
                    if error != nil {
                        print("There was an error with downloading the image file.")
                        print(error)
                        dispatch_async(dispatch_get_main_queue(), {
                            let alert = UIAlertController(title: "There was an error with downloading the image file. \(error!.localizedDescription)", message: nil, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.imageView.image = UIImage(data: data!)
                        })
                    }
                }
                task.resume()
            }
        }
        if let title = mapPoint?.title {
            titleLabel.text = title
        }
        if let address = mapPoint?.address {
            addressLabel.text = address
        }
    }
    
// Stops the sound and removes the time observer when the user decides to change the tab or goes back to map
    override func viewWillDisappear(animated: Bool) {
        if avPlayer != nil {
            if avPlayer.rate != 0 && avPlayer.error == nil {
                avPlayer.pause()
            }
            if timeObserver != nil {
                avPlayer.removeTimeObserver(timeObserver)
            }
        }
        avPlayer = nil
    }
}
