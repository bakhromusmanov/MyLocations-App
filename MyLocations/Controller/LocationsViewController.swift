//
//  LocationsTableViewController.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 27/11/24.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
   
   //MARK: Custom Variable
   var managedObjectContext: NSManagedObjectContext!
   
   //MARK: Fetched Result Controller
   lazy var fetchedResultController: NSFetchedResultsController = {
      let fetchRequest = NSFetchRequest<Location>()
      let entity = Location.entity()
      fetchRequest.entity = entity
      
      let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
      let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
      fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
      fetchRequest.fetchBatchSize = 20
      
      let fetchedResultController = NSFetchedResultsController(
         fetchRequest: fetchRequest,
         managedObjectContext: self.managedObjectContext,
         sectionNameKeyPath: "category",
         cacheName: "Locations"
      )
      fetchedResultController.delegate = self
      
      return fetchedResultController
   }()
   
   //MARK: - ViewDidLoad
   override func viewDidLoad() {
      super.viewDidLoad()
      performFetch()
      updateEditButtonVisibility()
   }
   
   deinit {
      fetchedResultController.delegate = nil
   }
   
   //MARK: - Custom Functions
   func updateEditButtonVisibility() {
      if let sectionInfo = fetchedResultController.sections?.first, sectionInfo.numberOfObjects > 0 {
         navigationItem.rightBarButtonItem = editButtonItem
      } else {
         setEditing(false, animated: true)
         navigationItem.rightBarButtonItem = nil
      }
   }
   
   //MARK: Fetch Locations From Core Data
   func performFetch() {
      do {
         try fetchedResultController.performFetch()
      } catch {
         fatalCoreDataError(error)
      }
   }
   
   //MARK: - Navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "EditLocation" {
         let controller = segue.destination as! LocationDetailsViewController
         controller.managedObjectContext = managedObjectContext
         if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
            let location = fetchedResultController.object(at: indexPath)
            controller.locationToEdit = location
         }
      }
   }
   
   // MARK: - Table View Data Source
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      let sectionInfo = fetchedResultController.sections![section]
      return sectionInfo.numberOfObjects
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
      let location = fetchedResultController.object(at: indexPath)
      cell.configure(for: location)
      
      return cell
   }
   
   override func numberOfSections(in tableView: UITableView) -> Int {
      return fetchedResultController.sections!.count
   }
   
   override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      let sectionInfo = fetchedResultController.sections![section]
      return sectionInfo.name
   }
   
   //MARK: - Table View Delegate
   override func tableView(
      _ tableView: UITableView,
      commit editingStyle: UITableViewCell.EditingStyle,
      forRowAt indexPath: IndexPath
   ) {
      if editingStyle == .delete {
         let location = fetchedResultController.object(at: indexPath)
         location.removePhotoFile()
         managedObjectContext.delete(location)
         
         do {
            try managedObjectContext.save()
         } catch {
            fatalCoreDataError(error)
         }
      }
   }
}

//MARK: - extension NSFetchedResultsControllerDelegate
extension LocationsViewController : NSFetchedResultsControllerDelegate {
   func controllerWillChangeContent(
      _ controller: NSFetchedResultsController<any NSFetchRequestResult>
   ) {
      tableView.beginUpdates()
   }
   
   func controller(
      _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
      didChange anObject: Any,
      at indexPath: IndexPath?,
      for type: NSFetchedResultsChangeType,
      newIndexPath: IndexPath?
   ) {
      switch type {
      case .insert:
         tableView.insertRows(at: [newIndexPath!], with: .fade)
      case .delete:
         tableView.deleteRows(at: [indexPath!], with: .fade)
      case .move:
         tableView.deleteRows(at: [indexPath!], with: .fade)
         tableView.insertRows(at: [newIndexPath!], with: .fade)
      case .update:
         if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
            let location = fetchedResultController.object(at: indexPath!)
            cell.configure(for: location)
         }
      @unknown default:
         print("*** NSFetchedResults unknown type")
      }
   }
   
   func controller(
      _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
      didChange sectionInfo: any NSFetchedResultsSectionInfo,
      atSectionIndex sectionIndex: Int,
      for type: NSFetchedResultsChangeType
   ) {
      switch type {
      case .insert:
         tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
      case .delete:
         tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
      default:
         break
      }
   }
   
   func controllerDidChangeContent(
      _ controller: NSFetchedResultsController<any NSFetchRequestResult>
   ) {
      tableView.endUpdates()
      updateEditButtonVisibility()
   }
}


