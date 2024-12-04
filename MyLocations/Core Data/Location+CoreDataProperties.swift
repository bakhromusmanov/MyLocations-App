//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 22/11/24.
//
//

import Foundation
import CoreData
import CoreLocation

extension Location {
   
   @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
      return NSFetchRequest<Location>(entityName: "Location")
   }
   @NSManaged public var photoID: NSNumber?
   @NSManaged public var latitude: Double
   @NSManaged public var longitude: Double
   @NSManaged public var date: Date
   @NSManaged public var category: String
   @NSManaged public var locationDescription: String
   @NSManaged public var placemark: CLPlacemark?
   
}

extension Location : Identifiable {
   
}
