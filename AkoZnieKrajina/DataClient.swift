//
//  DataClient.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 21/12/15.
//  Copyright © 2015 Peter Krajcir. All rights reserved.
//

import Foundation

class DataClient: NSObject {
    var session: NSURLSession
    
    // MARK: Init
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
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
    
    // MARK: Shared Instance
    static let sharedInstance = DataClient()
}