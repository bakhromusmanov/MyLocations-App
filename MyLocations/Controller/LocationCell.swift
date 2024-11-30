//
//  LocationCell.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 27/11/24.
//

import UIKit

class LocationCell: UITableViewCell {
   
   @IBOutlet weak var descriptionLabel: UILabel!
   @IBOutlet weak var addressLabel: UILabel!
   
   func configure(for location: Location) {
      
      if location.locationDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
         descriptionLabel.text = "No Description"
      } else {
         descriptionLabel.text = location.locationDescription
      }
      
      if let placemark = location.placemark {
         var text = ""
         
         if let tmp = placemark.subThoroughfare {
            text += tmp + " "
         }
         
         if let tmp = placemark.thoroughfare {
            text += tmp + ", "
         }
         
         if let tmp = placemark.locality {
            text += tmp
         }
         
         addressLabel.text = text
      } else {
         addressLabel.text = String(
            format: "Lat: %.8f, Long: %.8f",
            location.latitude,
            location.longitude)
      }
   }

}
