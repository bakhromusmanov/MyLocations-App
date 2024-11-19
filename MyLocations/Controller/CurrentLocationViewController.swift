//
//  ViewController.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 04/11/24.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
   
   //MARK: - Interface Builder variables
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
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      navigationController?.navigationBar.isHidden = true
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      navigationController?.navigationBar.isHidden = false
   }
   
   //MARK: - Custom variables
   var timer: Timer?
   
   //MARK: - Location Manager variables
   let locationManager = CLLocationManager()
   var location: CLLocation?
   var lastLocationError: Error?
   var updatingLocation = false
   
   //MARK: - Reverse Geocoding Variables
   let geocoder = CLGeocoder()
   var placemark: CLPlacemark?
   var performingReverseGeocoding = false
   var lastGeocodingError: Error?
   
   
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
      
      if updatingLocation {
         stopLocationManager()
      } else {
         location = nil
         lastLocationError = nil
         placemark = nil
         lastGeocodingError = nil
         startLocationManager()
      }
      
      updateLabels()
   }
   
   //MARK: - Navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "TagLocation" {
         let controller = segue.destination as! LocationDetailsViewController
         controller.coordinate = location!.coordinate
         controller.placemark = placemark
      }
   }
   
   //MARK: - Custom functions
   func startLocationManager(){
      if CLLocationManager.locationServicesEnabled() {
         locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
         locationManager.startUpdatingLocation()
         updatingLocation = true
         
         timer = Timer.scheduledTimer(
               timeInterval: 30,
               target: self,
               selector: #selector(didTimeOut),
               userInfo: nil,
               repeats: false)
      }
   }
   
   @objc func didTimeOut() {
      stopLocationManager()
      updateLabels()
      if location == nil {
         print("***Time Out Error Finding Location")
         lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
      }
   }
   
   func stopLocationManager(){
      if updatingLocation {
         locationManager.stopUpdatingLocation()
         locationManager.delegate = nil
         updatingLocation = false
         
         if let timer = timer {
            timer.invalidate()
         }
      }
   }
   
   func configureGetButton() {
      if updatingLocation {
         getButton.setTitle("Stop", for: .normal)
      } else {
         getButton.setTitle("Get My Location", for: .normal)
      }
   }
   
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
      //Update Location
      if let location = location {
         latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
         longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
         tagButton.isHidden = false
         if updatingLocation {
            messageLabel.text = "Current Location"
         } else {
            messageLabel.text = "Tap 'Get My Location' to Start"
         }
         
         //Update Adress Reverse Geocoding
         if let placemark = placemark {
            addressLabel.text = string(from: placemark)
         } else if performingReverseGeocoding {
            addressLabel.text = "Searching for Address..."
         } else if lastGeocodingError != nil {
            addressLabel.text = "Error Finding Address"
         } else {
            addressLabel.text = "No Address Found"
         }
      } else {
         latitudeLabel.text = ""
         longitudeLabel.text = ""
         addressLabel.text = ""
         tagButton.isHidden = true
         
         //Update Message Label in case of errors
         let statusMessage: String
         if let error = lastLocationError as NSError? {
            if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
               statusMessage = "Location Services were Denied"
            } else {
               statusMessage = "Error Getting Location"
            }
         } else if !CLLocationManager.locationServicesEnabled() {
            statusMessage = "Location Services Disabled"
         } else if updatingLocation {
            statusMessage = "Searching..."
         } else {
            statusMessage = "Tap 'Get My Location' to Start"
         }
         messageLabel.text = statusMessage
      }
      configureGetButton()
   }
   
   func string(from placemark: CLPlacemark) -> String {
      var line1 = ""
      
      if let tmp = placemark.subThoroughfare {
         line1 += tmp + " "
      }
      
      if let tmp = placemark.thoroughfare {
         line1 += tmp
      }
      
      var line2 = ""
      
      if let tmp = placemark.locality {
         line2 += tmp + " "
      }
      
      if let tmp = placemark.administrativeArea {
         line2 += tmp + " "
      }
      
      if let tmp = placemark.postalCode {
         line2 += tmp
      }
      
      return line1 + "\n" + line2
   }
   
   //MARK: - Core Location Manager Delegates
   func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
      print("Did fail to fetch location with error: \(error.localizedDescription)")
      
      if (error as NSError).code == CLError.locationUnknown.rawValue {
         return
      }
      
      lastLocationError = error
      stopLocationManager()
      updateLabels()
   }
   
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
      guard let newLocation = locations.last else { return }
      print("DidUpdateLocations \(newLocation)")
      
      if newLocation.timestamp.timeIntervalSinceNow < -5 {
         return
      }
      
      if newLocation.horizontalAccuracy < 0 {
         return
      }
      
      var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
      if let location = location {
         distance = location.distance(from: newLocation)
      }
      
      if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
         lastLocationError = nil
         location = newLocation
         
         if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            print("*** We're done!")
            stopLocationManager()
            
            if distance > 0 {
               performingReverseGeocoding = false
            }
         }
         updateLabels()
      } else if distance < 1 {
         let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
         if timeInterval > 10 {
            print("*** Force Stop Location Manager")
            stopLocationManager()
            updateLabels()
         }
      }
      
      // Start reverse geocoding
      if !performingReverseGeocoding {
         print("*** Starting Reverse Geocoding")
         performingReverseGeocoding = true
         
         geocoder.reverseGeocodeLocation(newLocation) { placemarks, error in
            self.lastGeocodingError = error
            if error == nil, let places = placemarks, !places.isEmpty {
               self.placemark = places.last!
            } else {
               self.placemark = nil
            }
            self.performingReverseGeocoding = false
            self.updateLabels()
         }
      }
   }
}


