//
//  Pin2.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 08/01/16.
//  Copyright © 2016 Peter Krajcir. All rights reserved.
//

import Foundation
import MapKit

class Pin2 {
    struct Keys {
        static let EntityName = "Pin"
        
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Address = "address"
        static let SoundURL = "soundURL"
        static let Id = "id"
    }
    
     var latitude: Double
     var longitude: Double
     var address: String?
     var soundUrl: String
     var id: Int
    
    
    init(dictionary: [String : AnyObject?]) {
        

        
        print(dictionary)
        print(dictionary["soundURL"])
        // Dictionary
        
        soundUrl = dictionary[Keys.SoundURL] as! String
        id = (dictionary[Keys.Id] as! NSString).integerValue
        latitude = (dictionary[Keys.Latitude] as! NSString).doubleValue
        longitude = (dictionary[Keys.Longitude] as! NSString).doubleValue
        address = dictionary[Keys.Address] as? String
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    var soundPath: String? {
        get {
            return soundUrl.stringByReplacingOccurrencesOfString("/", withString: "_").stringByReplacingOccurrencesOfString(":", withString: "_")
        }
    }
}
