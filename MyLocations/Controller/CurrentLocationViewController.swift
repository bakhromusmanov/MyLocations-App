//
//  ViewController.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 04/11/24.
//

import UIKit
import CoreLocation
import CoreData
import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate {
   
   //MARK: - Interface Builder variables
   @IBOutlet weak var messageLabel: UILabel!
   @IBOutlet weak var latitudeLabel: UILabel!
   @IBOutlet weak var longitudeLabel: UILabel!
   @IBOutlet weak var latitudeTextLabel: UILabel!
   @IBOutlet weak var longitudeTextLabel: UILabel!
   @IBOutlet weak var addressLabel: UILabel!
   @IBOutlet weak var tagButton: UIButton!
   @IBOutlet weak var getButton: UIButton!
   @IBOutlet weak var containerView: UIView!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      loadSoundEffect("Sound.caf")
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
   
   deinit {
      unloadSoundEffect()
   }
   
   //MARK: - Custom variables
   var timer: Timer?
   var managedObjectContext: NSManagedObjectContext!
   var logoVisible = false
   lazy var logoButton: UIButton = {
      let button = UIButton(type: .custom)
      button.setBackgroundImage(
         UIImage(named: "Logo"), for: .normal)
      button.sizeToFit()
      button.addTarget(
         self, action: #selector(getLocation), for: .touchUpInside)
      button.center.x = self.view.bounds.midX
      button.center.y = 220
      return button
   }()
   var soundID: SystemSoundID = 0
   
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
      
      if logoVisible {
         hideLogoView()
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
         controller.managedObjectContext = managedObjectContext
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
       let spinnerTag = 1000
       if updatingLocation {
           getButton.setTitle("Stop", for: .normal)
           if view.viewWithTag(spinnerTag) == nil {
               let spinner = UIActivityIndicatorView(style: .medium)
               spinner.center = messageLabel.center
               spinner.center.y += spinner.bounds.size.height / 2 + 25
               spinner.startAnimating()
               spinner.tag = spinnerTag
               containerView.addSubview(spinner)
           }
       } else {
           getButton.setTitle("Get My Location", for: .normal)
           if let spinner = view.viewWithTag(spinnerTag) {
               spinner.removeFromSuperview()
           }
       }
   }
   
   //MARK: Show Alert
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
      //MARK: Update Location
      if let location = location {
         latitudeTextLabel.isHidden = false
         longitudeTextLabel.isHidden = false
         latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
         longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
         tagButton.isHidden = false
         if updatingLocation {
            messageLabel.text = "Searching..."
         } else {
            messageLabel.text = "Current Location"
         }
         
         //MARK: Update Address
         
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
         latitudeTextLabel.isHidden = true
         longitudeTextLabel.isHidden = true
         
         //MARK: Update Status Message
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
            statusMessage = "Tap 'Get Location' to Start"
            showLogoView()
         }
         messageLabel.text = statusMessage
      }
      configureGetButton()
   }
   
   //MARK: Convert Placemark to Readable Address
   
   func string(from placemark: CLPlacemark) -> String {
      var line1 = ""
      line1.add(text: placemark.subThoroughfare, separatedBy: " ")
      line1.add(text: placemark.thoroughfare)
      
      var line2 = ""
      line2.add(text: placemark.locality, separatedBy: " ")
      line2.add(text: placemark.administrativeArea, separatedBy: " ")
      line2.add(text: placemark.postalCode, separatedBy: " ")
      line2.add(text: placemark.country)
      
      line1.add(text: "\n", separatedBy: line2)
      return line1
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
      
      //MARK: Start Updating Location
      
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
      
      //MARK: - Start reverse geocoding
      if !performingReverseGeocoding {
         print("*** Starting Reverse Geocoding")
         performingReverseGeocoding = true
         
         geocoder.reverseGeocodeLocation(newLocation) { placemarks, error in
            self.lastGeocodingError = error
            if error == nil, let places = placemarks, !places.isEmpty {
               if self.placemark == nil {
                   self.playSoundEffect()
               }
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

//MARK: Core Animation Delegate
extension CurrentLocationViewController {
   
   //MARK: Logo Animation
   func showLogoView() {
      if !logoVisible {
         logoVisible = true
         containerView.isHidden = true
         view.addSubview(logoButton)
      } }
   
   func hideLogoView() {
      if !logoVisible { return }
      logoVisible = false
      containerView.isHidden = false
      containerView.center.x = view.bounds.size.width * 2
      containerView.center.y = 40 + containerView.bounds.size.height / 2
      let centerX = view.bounds.midX
      
      // Panel animation
      let panelMover = CABasicAnimation(keyPath: "position")
      panelMover.isRemovedOnCompletion = false
      panelMover.fillMode = .forwards
      panelMover.duration = 0.6
      panelMover.fromValue = NSValue(cgPoint: containerView.center)
      panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
      panelMover.timingFunction = CAMediaTimingFunction(name: .easeOut)
      panelMover.delegate = self
      containerView.layer.add(panelMover, forKey: "panelMover")
      
      // Logo slide animation
      let logoMover = CABasicAnimation(keyPath: "position")
      logoMover.isRemovedOnCompletion = false
      logoMover.fillMode = .forwards
      logoMover.duration = 0.5
      logoMover.fromValue = NSValue(cgPoint: logoButton.center)
      logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
      logoMover.timingFunction = CAMediaTimingFunction(name: .easeIn)
      logoButton.layer.add(logoMover, forKey: "logoMover")
      
      // Logo rotation animation
      let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
      logoRotator.isRemovedOnCompletion = false
      logoRotator.fillMode = .forwards
      logoRotator.duration = 0.5
      logoRotator.fromValue = 0.0
      logoRotator.toValue = -2 * Double.pi
      logoRotator.timingFunction = CAMediaTimingFunction(name: .easeIn)
      logoButton.layer.add(logoRotator, forKey: "logoRotator")
   }
   
   func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
      containerView.layer.removeAllAnimations()
      containerView.center.x = view.bounds.size.width / 2
      containerView.center.y = 40 + containerView.bounds.size.height / 2
      logoButton.layer.removeAllAnimations()
      logoButton.removeFromSuperview()
   }
   
}

//MARK: Audio ToolBox Sound Effects
extension CurrentLocationViewController {
   
   func loadSoundEffect(_ name: String) {
       if let path = Bundle.main.path(forResource: name, ofType: nil) {
           let fileURL = URL(fileURLWithPath: path, isDirectory: false)
           let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
           if error != kAudioServicesNoError {
               print("Error code \(error) loading sound: \(path)")
           }
       }
   }

   func unloadSoundEffect() {
       AudioServicesDisposeSystemSoundID(soundID)
       soundID = 0
   }

   func playSoundEffect() {
       AudioServicesPlaySystemSound(soundID)
   }
}


