//
//  ViewController.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 04/11/24.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
   
   //MARK: - IBOutlet variables
   @IBOutlet weak var messageLabel: UILabel!
   @IBOutlet weak var latitudeLabel: UILabel!
   @IBOutlet weak var longitudeLabel: UILabel!
   @IBOutlet weak var addressLabel: UILabel!
   @IBOutlet weak var tagButton: UIButton!
   @IBOutlet weak var getButton: UIButton!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      updateLabels()
   }
   
   //MARK: - Custom variables
   let locationManager = CLLocationManager()
   var location: CLLocation?
    
   //MARK: - IBAction functions
   @IBAction func getLocation(_ sender: UIButton) {
      let authStatus = locationManager.authorizationStatus
      
      if authStatus == .notDetermined {
         locationManager.requestWhenInUseAuthorization()
         return
      }
      
      if authStatus == .restricted || authStatus == .denied {
         showAccessDeniedAlert()
      }
      
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
   }
   
   //MARK: - Custom functions
   func showAccessDeniedAlert() {
      let alert = UIAlertController(
         title: "Location Services Disabled",
         message: "Please enable location services for this app in Settings.",
         preferredStyle: .alert)
      let okAction = UIAlertAction(
         title: "OK",
         style: .default,
         handler: nil)
      alert.addAction(okAction)
      present(alert, animated: true, completion: nil)
   }
   
   func updateLabels(){
      if let location = location {
         latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
         longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
         tagButton.isHidden = false
         messageLabel.text = ""
      } else {
         latitudeLabel.text = ""
         longitudeLabel.text = ""
         addressLabel.text = ""
         tagButton.isHidden = true
         messageLabel.text = "Tap 'Get My Location' to Start"
      }
   }
   
   //MARK: - Core Location Manager Delegates
   func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
      print("Did fail to fetch location with error: \(error.localizedDescription)")
   }
   
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let newLocation = locations.last {
         print("Did update locations with new location \(newLocation)")
         location = newLocation
         updateLabels()
      }
   }
}

