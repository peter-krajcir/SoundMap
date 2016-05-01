//
//  DataClient-Constants.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 21/12/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

//  Extension for DataClient library
//  It contains information for the webservice, specifically the communication API and keys in the returned json from the server

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
            static let Title = "markername"
            static let ImageURL = "image"
        }
    }
}