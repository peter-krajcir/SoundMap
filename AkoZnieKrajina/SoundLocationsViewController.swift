//
//  SoundLocationsViewController.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 21/12/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class SoundLocationsViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restoreMapRegion(true)
        
        mapView.delegate = self
        
        fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        
        DataClient.sharedInstance.getPins { (JSONResult, errorString) in
            var loadingFailed = false
            
            if let errorString = errorString {
                loadingFailed = true
                print(errorString)
            } else {
                if let pins = JSONResult as [[String: AnyObject]]? {
                    self.removeAllPinsFromCoreData()
                    var pinsForRendering: [Pin] = [Pin]()
                    for parsedPin in pins {
                        
                        let dictionary: [String: AnyObject?] = [
                            Pin.Keys.Id: parsedPin[DataClient.Constants.Json.Id],
                            Pin.Keys.Latitude: parsedPin[DataClient.Constants.Json.Latitude],
                            Pin.Keys.Longitude: parsedPin[DataClient.Constants.Json.Longitude],
                            Pin.Keys.Address: parsedPin[DataClient.Constants.Json.Address],
                            Pin.Keys.SoundURL: parsedPin[DataClient.Constants.Json.SoundURL]
                        ]
                        
                        let pin = Pin(dictionary: dictionary, context: self.sharedContext)
                        pinsForRendering.append(pin)
                        self.sharedContext.insertObject(pin)
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.renderAnnotations(pinsForRendering)
                    }

                } else {
                    loadingFailed = true
                    print("No Pins found")
                }
            }
            
            if loadingFailed {
                // let's try to load the Core Data object
                
                if let pins = self.fetchedResultsController.fetchedObjects as? [Pin] {
                    print("Fetched pins")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.renderAnnotations(pins)
                    }
                }
            }
        }
    }
    
    func renderAnnotations(pins:[Pin]) {
        for pin in pins {
            mapView.addAnnotation(pin)
        }
    }
    
    func removeAllPinsFromCoreData() {
        if let pins = self.fetchedResultsController.fetchedObjects as? [Pin] {
//            print("Removing all pins from Core Data")
            for pin in pins {
                self.sharedContext.deleteObject(pin)
                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
    }

    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Pin.Keys.EntityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Pin.Keys.Longitude, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        print("controllerDidChangeContent called")
    }
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    func saveMapRegion() {
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }

    func restoreMapRegion(animated: Bool) {
        
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            print("lat: \(latitude), lon: \(longitude), latD: \(latitudeDelta), lonD: \(longitudeDelta)")
            
            mapView.setRegion(savedRegion, animated: animated)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }

}

