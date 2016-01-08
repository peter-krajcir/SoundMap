//
//  DataClient-Constants.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 21/12/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import Foundation

extension DataClient {
    struct Constants {
        static let Url = "http://akozniekrajina.sk/app/data.php"
        
        struct Json {
            static let Address = "address"
            static let Id = "id"
            static let Latitude = "lat"
            static let Longitude = "lon"
            static let SoundURL = "mp3"
        }
    }
}