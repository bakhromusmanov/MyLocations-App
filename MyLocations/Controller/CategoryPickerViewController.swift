//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 18/11/24.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
   
   var selectedCategoryName = ""
   var selectedIndexPath = IndexPath()
   weak var delegate: CategoryPickerViewControllerDelegate?
   
   let categories = [
      "No Category",
      "Apple Store",
      "Bar",
      "Bookstore",
      "Club",
      "Grocery Store",
      "Historic Building",
      "House",
      "Icecream Vendor",
      "Landmark",
      "Park"
   ]
   
   override func viewDidLoad() {
      super.viewDidLoad()
      let index = categories.firstIndex(where: {$0 == selectedCategoryName})!
      selectedIndexPath = IndexPath(row: index, section: 0)
   }
   
   // MARK: - Table View data source
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return categories.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Category", for: indexPath)
      let categoryName = cell.viewWithTag(1001) as! UILabel
      categoryName.text = categories[indexPath.row]
      
      if categoryName.text == selectedCategoryName {
         cell.accessoryType = .checkmark
      } else {
         cell.accessoryType = .none
      }
      
      return cell
   }
   
   //MARK: - Table View delegates
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard indexPath != selectedIndexPath else { return }
      
      if let cell = tableView.cellForRow(at: indexPath) {
         delegate?.categoryPicker(self, didPickCategory: categories[indexPath.row])
         selectedCategoryName = categories[indexPath.row]
         cell.accessoryType = .checkmark
      }
      
      navigationController?.popViewController(animated: true)
   }
   
}

protocol CategoryPickerViewControllerDelegate : AnyObject {
   func categoryPicker(_ controller: CategoryPickerViewController, didPickCategory name: String)
}
