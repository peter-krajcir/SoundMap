//
//  Pin.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 22/12/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Pin)

class Pin: NSManagedObject, MKAnnotation {
    struct Keys {
        static let EntityName = "Pin"
        
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Address = "address"
        static let SoundURL = "soundURL"
        static let Id = "id"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var address: String?
    @NSManaged var soundUrl: String
    @NSManaged var id: Int
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject?], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName(Keys.EntityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

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
