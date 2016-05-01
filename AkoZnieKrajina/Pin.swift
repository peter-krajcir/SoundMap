//
//  Pin.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 22/12/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

//  Main class used in CoreData
//  It contains all the information about the Pin and Sound

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
        static let Filename = "filename"
        static let Id = "id"
        static let Title = "title"
        static let ImageURL = "imageURL"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var address: String?
    @NSManaged var soundUrl: String
    @NSManaged var filename: String?
    @NSManaged var id: Int64
    @NSManaged var title: String?
    @NSManaged var imageUrl: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(mapPoint: MapPoint, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName(Keys.EntityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        // Dictionary
        
        soundUrl = mapPoint.soundUrl
        filename = mapPoint.filename
        id = mapPoint.id
        latitude = mapPoint.latitude
        longitude = mapPoint.longitude
        address = mapPoint.address
        title = mapPoint.title
        imageUrl = mapPoint.imageUrl
    }
    
//  Convenient function - getter
//  Generates the Pin's coordinates from information in the object
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
//  Reference for MapPoint class that is used in the Player screen
    
    var mapPoint: MapPoint? {
        get {
            return MapPoint(pin: self)
        }
    }
}
