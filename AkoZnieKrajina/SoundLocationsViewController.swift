//
//  SoundLocationsViewController.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 21/12/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import UIKit
import MapKit

class SoundLocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restoreMapRegion(true)
        
        mapView.delegate = self
        
// Get all the pins from the server
        DataClient.sharedInstance.getPins { (JSONResult, errorString) in
            
            if let errorString = errorString {
                print(errorString)
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: errorString, message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } else {
// Loop through the results returned from the server and display them in the map
                if let mapPoints = JSONResult as [[String: AnyObject]]? {
                    var mapPointsForRendering: [MapPoint] = [MapPoint]()
                    for parsedMapPoint in mapPoints {
                        
                        let dictionary: [String: AnyObject?] = [
                            Pin.Keys.Id: parsedMapPoint[DataClient.Constants.Json.Id],
                            Pin.Keys.Latitude: parsedMapPoint[DataClient.Constants.Json.Latitude],
                            Pin.Keys.Longitude: parsedMapPoint[DataClient.Constants.Json.Longitude],
                            Pin.Keys.Address: parsedMapPoint[DataClient.Constants.Json.Address],
                            Pin.Keys.SoundURL: parsedMapPoint[DataClient.Constants.Json.SoundURL],
                            Pin.Keys.Title: parsedMapPoint[DataClient.Constants.Json.Title],
                            Pin.Keys.ImageURL: parsedMapPoint[DataClient.Constants.Json.ImageURL]
                        ]
// We don't want to display the pins without the actual sound
                        if dictionary[Pin.Keys.SoundURL] as? String == nil {
                            continue
                        }
                        
                        let mapPoint = MapPoint(dictionary: dictionary)
                        mapPointsForRendering.append(mapPoint)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.renderAnnotations(mapPointsForRendering)
                    }
                }
            }
        }
    }
    
// Add the Pin to the map
    func renderAnnotations(mapPoints:[MapPoint]) {
        for mapPoint in mapPoints {
            mapView.addAnnotation(mapPoint)
        }
    }
    
// Filepath for saving the position on the map
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
// Saving the position on the map
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

// Restoring the position on the map
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
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapPoint {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        } else {
            return nil
        }
    }
    
// Action when the User clicked on Pin's annotation
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MapPoint {
            performSegueWithIdentifier("displayMapPointDetail", sender: annotation)
        }
    }
    
// We pass the selected Pin to displayMapPointDetail view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "displayMapPointDetail" {
            let mapPointDetailViewController = segue.destinationViewController as! MapPointDetailViewController
            let mapPoint = sender as! MapPoint
            mapPointDetailViewController.mapPoint = mapPoint
        }
    }

}

