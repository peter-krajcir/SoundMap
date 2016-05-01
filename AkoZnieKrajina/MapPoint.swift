//
//  MapPoint.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 22/01/16.
//  Copyright © 2016 Peter Krajcir. All rights reserved.
//

import Foundation
import MapKit

class MapPoint: NSObject, MKAnnotation {
    
    var latitude: Double
    var longitude: Double
    var address: String?
    var soundUrl: String
    var filename: String?
    var id: Int64
    var title: String?
    var imageUrl: String?
    
    init(dictionary: [String : AnyObject?]) {
        // Dictionary
        
        soundUrl = dictionary[Pin.Keys.SoundURL] as! String
        filename = dictionary[Pin.Keys.Filename] as? String
        id = (dictionary[Pin.Keys.Id] as! NSString).longLongValue
        latitude = (dictionary[Pin.Keys.Latitude] as! NSString).doubleValue
        longitude = (dictionary[Pin.Keys.Longitude] as! NSString).doubleValue
        address = dictionary[Pin.Keys.Address] as? String
        title = dictionary[Pin.Keys.Title] as? String
        imageUrl = dictionary[Pin.Keys.ImageURL] as? String
    }
    
    convenience init(pin: Pin) {
        let dictionary: [String: AnyObject?] = [
            Pin.Keys.Id: String(pin.id),
            Pin.Keys.Latitude: String(pin.latitude),
            Pin.Keys.Longitude: String(pin.longitude),
            Pin.Keys.Address: pin.address,
            Pin.Keys.SoundURL: pin.soundUrl,
            Pin.Keys.Filename: pin.filename,
            Pin.Keys.Title: pin.title,
            Pin.Keys.ImageURL: pin.imageUrl
        ]
        self.init(dictionary: dictionary)
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}