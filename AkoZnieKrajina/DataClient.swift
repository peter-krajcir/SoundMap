//
//  DataClient.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 21/12/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//


// DataClient library
// This library is communication gateway between the application and the target webservice

import Foundation

class DataClient: NSObject {
    var session: NSURLSession
    
    // MARK: Init
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
//  Get all the pins from the webservice and return them in JSON format
    func getPins(callback: (JSONResult: [[String: AnyObject]]!, errorString: String?)->Void) {
        let url = NSURL(string: Constants.Url)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard (error == nil) else {
                callback(JSONResult: nil, errorString: "There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                callback(JSONResult: nil, errorString: "No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                callback(JSONResult: nil, errorString: "Could not parse the data as JSON!")
                print("\(data)")
                return
            }
//            print("\(parsedResult)")
            guard let pinArray = parsedResult as? [[String: AnyObject]] else {
                callback(JSONResult: nil, errorString: "Incompatible format of returned data!")
                print("Incompatible format of returned data!")
                return
            }
            
            callback(JSONResult: pinArray, errorString: nil)
        }
        
        task.resume()
    }
    
    
//  Download the selected file in soundUrl and store it in the application's document folder
//  The function returns the target filename that is the same as the filename in the server, we keep the same name for the files
    func downloadSound(soundUrl: String, callback: (targetFilename: String?, errorString: String?)->Void) {
        let url = NSURL(string: soundUrl)!
        
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let destinationUrl = documentsDirectoryURL.URLByAppendingPathComponent(url.lastPathComponent!)
        
        print(destinationUrl)
        
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            callback(targetFilename: nil, errorString: "File already exists (\(destinationUrl.path!))!")
            return
        } else {
            let request = NSURLRequest(URL: url)
            
            let task = session.dataTaskWithRequest(request) { (data, response, error) in
                guard (error == nil) else {
                    callback(targetFilename: nil, errorString: "There was an error with your request: \(error)")
                    return
                }
                
                guard let data = data else {
                    callback(targetFilename: nil, errorString: "No data was returned by the request!")
                    return
                }
                
                if data.writeToURL(destinationUrl, atomically: true) {
                    print("file saved to \(destinationUrl)")
                    callback(targetFilename: url.lastPathComponent!, errorString: nil)
                } else {
                    print("error saving file")
                    callback(targetFilename: nil, errorString: "Error saving file to \(destinationUrl.absoluteString)")
                }
            }
            
            task.resume()
        }
    }
    
//  Helper function
//  For the provided filename (identifier), it generates the full path for the application's document folder
//  It's used when we are downloading the file and we need to provide the path where the file should be saved
//  We also use it when we want to play the file
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
    
//  Helper function
//  It returns the path to application's document directory
    func pathToDocs() -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return documentsDirectoryURL.absoluteString
    }
    
    // MARK: Shared Instance
    static let sharedInstance = DataClient()
}