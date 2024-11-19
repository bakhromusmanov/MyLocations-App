//
//  TagLocationTableViewController.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 14/11/24.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
   let formatter = DateFormatter()
   formatter.dateStyle = .medium
   formatter.timeStyle = .short
   return formatter
}()

class LocationDetailsViewController: UITableViewController, CategoryPickerViewControllerDelegate {
   
   //MARK: - IBOutlets
   @IBOutlet weak var descriptionTextView: UITextView!
   @IBOutlet weak var categoryLabel: UILabel!
   @IBOutlet weak var latitudeLabel: UILabel!
   @IBOutlet weak var longitudeLabel: UILabel!
   @IBOutlet weak var addressLabel: UILabel!
   @IBOutlet weak var dateLabel: UILabel!
   
   //MARK: Custom Variables
   var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
   var placemark: CLPlacemark?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      categoryLabel.text = "No Category"
      descriptionTextView.text = ""
      
      latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
      if let placemark = placemark {
         addressLabel.text = string(from: placemark)
      } else {
         addressLabel.text = "No Address Found"
      }
      
      dateLabel.text = format(date: Date())
   }
   
   //MARK: - IBActions
   @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
      navigationController?.popViewController(animated: true)
   }
   
   @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
      navigationController?.popViewController(animated: true)
   }
   
   //MARK: Custom Functions
   func string(from placemark: CLPlacemark?) -> String {
      var text = ""
      if let tmp = placemark?.subThoroughfare {
         text += tmp + " "
      }
      if let tmp = placemark?.thoroughfare {
         text += tmp + " "
      }
      if let tmp = placemark?.locality {
         text += tmp + " "
      }
      if let tmp = placemark?.administrativeArea {
         text += tmp + " "
      }
      if let tmp = placemark?.postalCode {
         text += tmp + " "
      }
      if let tmp = placemark?.country {
         text += tmp
      }
      return text
   }
   
   func format(date: Date) -> String {
      return dateFormatter.string(from: date)
   }
   
   //MARK: - Navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "PickCategory" {
         let controller = segue.destination as! CategoryPickerViewController
         controller.delegate = self
         controller.selectedCategoryName = categoryLabel.text!
      }
   }
}

extension LocationDetailsViewController {
   //MARK: - Custom Protocol Conformances
   func categoryPicker(_ controller: CategoryPickerViewController, didPickCategory name: String) {
      categoryLabel.text = name
   }
}
