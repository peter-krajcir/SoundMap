//
//  DownloadedSoundsTableViewController.swift
//  AkoZnieKrajina
//
//  Created by Petrik on 16/04/16.
//  Copyright © 2016 Peter Krajcir. All rights reserved.
//

import UIKit
import CoreData

class DownloadedSoundsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Pin.Keys.EntityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Pin.Keys.Title, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        print("controllerDidChangeContent called from DownloadedSounds")
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cnt = fetchedResultsController.sections![section].numberOfObjects
        return cnt
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let pin = fetchedResultsController.objectAtIndexPath(indexPath) as! Pin
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath)
        cell.textLabel!.text = pin.title
        
        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
// Get the new view controller using segue.destinationViewController.
// Pass the selected object to the new view controller.
        if segue.identifier == "toPlayDownloadedSoundSegue" {
            let vc = segue.destinationViewController as! MapPointDetailViewController
            let pin = fetchedResultsController.objectAtIndexPath(tableView.indexPathForSelectedRow!) as! Pin
            vc.mapPoint = pin.mapPoint
        }
    }

}
