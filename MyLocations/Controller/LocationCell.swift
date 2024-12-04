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
   @IBOutlet weak var photoImageView: UIImageView!
   
   func configure(for location: Location) {
      if location.locationDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
         descriptionLabel.text = "No Description"
      } else {
         descriptionLabel.text = location.locationDescription
      }
      
      if let placemark = location.placemark {
         var text = ""
         text.add(text: placemark.subThoroughfare, separatedBy: " ")
         text.add(text: placemark.thoroughfare, separatedBy: ", ")
         text.add(text: placemark.locality)
         addressLabel.text = text
         
         photoImageView.image = thumbnail(for: location)
      } else {
         addressLabel.text = String(
            format: "Lat: %.8f, Long: %.8f",
            location.latitude,
            location.longitude)
      }
   }
   
   func thumbnail(for location: Location) -> UIImage {
      if location.hasPhoto, let image = location.photoImage{
         return image.resize(withBounds: CGSize(width: 52, height: 52))
      }
      return UIImage(named: "No Photo")!
   }
   
   override func awakeFromNib() {
      super.awakeFromNib()
      photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
      photoImageView.clipsToBounds = true
      separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
   }
}
