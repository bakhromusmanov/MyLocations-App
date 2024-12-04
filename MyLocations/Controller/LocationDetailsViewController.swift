//
//  TagLocationTableViewController.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 14/11/24.
//

import UIKit
import CoreLocation
import CoreData

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
   @IBOutlet weak var imageView: UIImageView!
   @IBOutlet weak var imageHeight: NSLayoutConstraint!
   @IBOutlet weak var addPhotoLabel: UILabel!
   
   //MARK: - Custom Variables
   var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
   var placemark: CLPlacemark?
   var managedObjectContext: NSManagedObjectContext!
   var date = Date()
   var categoryName = "No Category"
   var descriptionText = ""
   var observer: Any!
   var locationToEdit: Location? {
      didSet {
         if let location = locationToEdit {
            title = "Edit Location"
            placemark = location.placemark
            date = location.date
            coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            categoryName = location.category
            descriptionText = location.locationDescription
         }
      }
   }
   var image: UIImage? {
      didSet {
         if let image = image {
            show(image: image)
         }
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      if let location = locationToEdit {
          if location.hasPhoto, let image = location.photoImage {
             show(image: image)
          }
      }

      listenForBackgroundNotification()
      
      descriptionTextView.text = descriptionText
      categoryLabel.text = categoryName
      latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
      if let placemark = placemark {
         addressLabel.text = string(from: placemark)
      } else {
         addressLabel.text = "No Address Found"
      }
      
      dateLabel.text = format(date: date)
      
      let gestureRecognizer = UITapGestureRecognizer(
         target: self,
         action: #selector(hideKeyboard)
      )
      gestureRecognizer.cancelsTouchesInView = false
      tableView.addGestureRecognizer(gestureRecognizer)
   }
   
   deinit {
      print(" deinit \(self)")
      NotificationCenter.default.removeObserver(observer!)
   }
   
   //MARK: - IBActions
   @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
      let location: Location
      let hudText: String
      
      if let temp = locationToEdit {
         hudText = "Updated"
         location = temp
      } else {
         hudText = "Tagged"
         location = Location(context: managedObjectContext)
         location.photoID = nil
      }
      
      location.locationDescription = descriptionTextView.text
      location.category = categoryName
      location.date = date
      location.latitude = coordinate.latitude
      location.longitude = coordinate.longitude
      location.placemark = placemark
      
      if let image = image {
         if !location.hasPhoto {
            location.photoID = Location.nextPhotoID() as NSNumber
         }

         if let data = image.jpegData(compressionQuality: 0.5) {
            do {
               try data.write(to: location.photoURL, options: .atomic)
            } catch {
               print("Error writing file: \(error.localizedDescription)")
            }
         }
      }
      
      do {
         try managedObjectContext.save()
         showHud(text: hudText, imageName: "Success")
      } catch {
         fatalCoreDataError(error)
      }
   }
   
   @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
      navigationController?.popViewController(animated: true)
   }
   
   //MARK: Custom Functions
   func listenForBackgroundNotification(){
      observer = NotificationCenter.default
         .addObserver(
            forName: UIScene.didEnterBackgroundNotification,
            object: nil,
            queue: OperationQueue.main,
            using: {[weak self] _ in
               if let weakSelf = self {
                  if weakSelf.presentedViewController != nil {
                     weakSelf.dismiss(animated: true)
                  }
                  weakSelf.descriptionTextView.resignFirstResponder()
               }
            })
   }
   
   func showHud(text: String, imageName: String) {
      guard let mainView = navigationController?.parent?.view else { return }
      
      let hudView = HudView.hud(inView: mainView, animated: true)
      hudView.text = text
      hudView.imageName = imageName
      afterDelay(0.6) {
         hudView.hide(animated: true)
         self.navigationController?.popViewController(animated: true)
         afterDelay(0.3) {
            hudView.hide()
         }
      }
   }
   
   @objc func hideKeyboard(_ gestureRecognizer: UITapGestureRecognizer) {
      let point = gestureRecognizer.location(in: tableView)
      let indexPath = tableView.indexPathForRow(at: point)
      
      if indexPath != nil && indexPath?.section == 0 && indexPath?.row == 0 {
         return
      }
         
      descriptionTextView.resignFirstResponder()
   }
   
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
         controller.selectedCategoryName = categoryName
      }
   }
   
   //MARK: - Table View Delegates
   override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      if indexPath.section == 0 || indexPath.section == 1 {
         return indexPath
      } else {
         return nil
      }
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if indexPath.row == 0 && indexPath.section == 0 {
         descriptionTextView.becomeFirstResponder()
      } else if indexPath.row == 0 && indexPath.section == 1 {
         tableView.deselectRow(at: indexPath, animated: true)
         pickPhoto()
      }
   }
}

//MARK: - Custom Protocol Conformances
extension LocationDetailsViewController {
   func categoryPicker(_ controller: CategoryPickerViewController, didPickCategory name: String) {
      categoryName = name
      categoryLabel.text = categoryName
   }
}

//MARK: - extension Image Picker
extension LocationDetailsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
   func show(image: UIImage) {
      imageView.isHidden = false
      imageView.image = image
      addPhotoLabel.text = ""
      
      view.layoutIfNeeded()

      let aspectRatio = image.size.width / image.size.height
      let newHeight = imageView.frame.width / aspectRatio
      imageHeight.constant = newHeight
      
      tableView.reloadData()
   }
   
   func pickPhoto() {
      if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
         showPhotoMenu()
      } else {
         choosePhotoFromLibrary()
      }
   }
   
   func showPhotoMenu() {
      let alert = UIAlertController(
         title: nil,
         message: nil,
         preferredStyle: .actionSheet)
      
      let actCancel = UIAlertAction(
         title: "Cancel",
         style: .cancel,
         handler: nil)
      alert.addAction(actCancel)
      
      let actPhoto = UIAlertAction(
         title: "Take Photo",
         style: .default,
         handler: { _ in
            self.takePhotoWithCamera()
         })
      alert.addAction(actPhoto)
      
      let actLibrary = UIAlertAction(
         title: "Choose From Library",
         style: .default,
         handler: { _ in
            self.choosePhotoFromLibrary()
         })
      alert.addAction(actLibrary)
      
      present(alert, animated: true, completion: nil)
   }
   
   func takePhotoWithCamera() {
      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .camera
      imagePicker.delegate = self
      imagePicker.allowsEditing = true
      present(imagePicker, animated: true)
   }
   
   func choosePhotoFromLibrary(){
      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .photoLibrary
      imagePicker.delegate = self
      imagePicker.allowsEditing = true
      present(imagePicker, animated: true)
   }
   
   //MARK: Image Picker Delegate Methods
   func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
   ) {
      image = info[.editedImage] as? UIImage
      picker.dismiss(animated: true)
   }
   
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true)
   }
}

