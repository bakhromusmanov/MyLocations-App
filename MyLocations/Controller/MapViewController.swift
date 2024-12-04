//
//  MapViewController.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 30/11/24.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController {
   
   @IBOutlet weak var mapView: MKMapView!
   
   //MARK: Custom Variables
   var managedObjectContext: NSManagedObjectContext! {
      didSet{
         NotificationCenter.default.addObserver(
            forName:
               Notification.Name.NSManagedObjectContextObjectsDidChange,
            object: managedObjectContext,
            queue: OperationQueue.main
         ) { notification in
            if self.isViewLoaded {
               self.updateCustomLocations(notification: notification)
            }
         }
      }
   }
   var locations = [Location]()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      updateLocations()
      if !locations.isEmpty {
         showLocations()
      }
   }
   
   //MARK: IBActions
   @IBAction func showUser() {
      let region = MKCoordinateRegion(
         center: mapView.userLocation.coordinate,
         latitudinalMeters: 1000,
         longitudinalMeters: 1000)
      mapView.setRegion(mapView.regionThatFits(region), animated: true)
   }
   
   @IBAction func showLocations() {
      let theRegion = region(for: locations)
      mapView.setRegion(theRegion, animated: true)
   }
   
   //MARK: Custom Functions
   
   func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
      
      let region: MKCoordinateRegion
      
      switch annotations.count {
      case 0:
         region = MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000)
         
      case 1:
         let annotation = annotations[0]
         region = MKCoordinateRegion(
            center: annotation.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000)
         
         
      default:
         var topLeft = CLLocationCoordinate2D(
            latitude: -90,
            longitude: 180)
         var bottomRight = CLLocationCoordinate2D(
            latitude: 90,
            longitude: -180)
         for annotation in annotations {
            topLeft.latitude = max(topLeft.latitude,
                                   annotation.coordinate.latitude)
            topLeft.longitude = min(topLeft.longitude,
                                    annotation.coordinate.longitude)
            bottomRight.latitude = min(bottomRight.latitude,
                                       annotation.coordinate.latitude)
            bottomRight.longitude = max(
               bottomRight.longitude,
               annotation.coordinate.longitude)
         }
         let center = CLLocationCoordinate2D(
            latitude: topLeft.latitude - (topLeft.latitude -
                                          bottomRight.latitude) / 2,
            longitude: topLeft.longitude - (topLeft.longitude -
                                            bottomRight.longitude) / 2)
         let extraSpace = 1.2
         let span = MKCoordinateSpan(
            latitudeDelta: abs(topLeft.latitude -
                               bottomRight.latitude) * extraSpace,
            longitudeDelta: abs(topLeft.longitude -
                                bottomRight.longitude) * extraSpace)
         region = MKCoordinateRegion(center: center, span: span)
      }
      return mapView.regionThatFits(region)
   }
   
   func updateCustomLocations(notification: Notification) {
      guard let dictionary = notification.userInfo else { return }
      
      guard performFetch() else { return }
      
      if let inserted = dictionary[NSInsertedObjectsKey] as? Set<Location> {
         for location in inserted {
            mapView.addAnnotation(location)
         }
      }
      
      if let updated = dictionary[NSUpdatedObjectsKey] as? Set<Location> {
            for location in updated {
               mapView.removeAnnotation(location)
               mapView.addAnnotation(location)
            }
      }
      
      if let deleted = dictionary[NSDeletedObjectsKey] as? Set<Location> {
         for location in deleted {
            mapView.removeAnnotation(location)
         }
      }
   }
   
   func updateLocations() {
      mapView.removeAnnotations(locations)
      
      if performFetch() {
         mapView.addAnnotations(locations)
      }
   }
   
   func performFetch() -> Bool {
      let fetchRequest = NSFetchRequest<Location>()
      let entity = Location.entity()
      fetchRequest.entity = entity
      
      do {
         locations = try managedObjectContext.fetch(fetchRequest)
         return true
      } catch {
         fatalCoreDataError(error)
         return false
      }
   }
   
   
   
   // MARK: - Navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "EditLocation" {
         let controller = segue.destination as! LocationDetailsViewController
         controller.managedObjectContext = managedObjectContext
         
         let button = sender as! UIButton
         let location = locations[button.tag]
         controller.locationToEdit = location
      }
   }
}

extension MapViewController : MKMapViewDelegate {
   func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
      guard annotation is Location else { return nil }
      
      let identifier = "Location"
      var annotationView = mapView.dequeueReusableAnnotationView(
         withIdentifier: identifier)
      
      if annotationView == nil {
         let pinView = MKMarkerAnnotationView(
            annotation: annotation,
            reuseIdentifier: identifier
         )
         
         // Configure pin view
         pinView.isEnabled = true
         pinView.canShowCallout = true
         pinView.animatesWhenAdded = true
         pinView.markerTintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
         
         //Add button
         let rightButton = UIButton(type: .detailDisclosure)
         rightButton.addTarget(
            self,
            action: #selector(showLocationDetails(_:)),
            for: .touchUpInside
         )
         rightButton.tintColor = .accent
         pinView.rightCalloutAccessoryView = rightButton
         annotationView = pinView
      }
      
      if let annotationView = annotationView {
         annotationView.annotation = annotation
         if let button = annotationView.rightCalloutAccessoryView as? UIButton,
            let index = locations.firstIndex(of: annotation as! Location) {
            button.tag = index
         }
      }
      
      return annotationView
   }
   
   @objc func showLocationDetails(_ sender: UIButton) {
      performSegue(withIdentifier: "EditLocation", sender: sender)
   }
}
