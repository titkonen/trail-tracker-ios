import UIKit
import CoreLocation

class SpotsViewController: UIViewController, CLLocationManagerDelegate {
  
  // MARK: OUTLETS
  @IBOutlet weak var getSpot: UIButton!
    @IBOutlet weak var saveSpot: UIButton!
    
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  
  // MARK: PROPERTIES
  var location: CLLocation? ///Storing the location
  let locationManager = CLLocationManager()
  var updatingLocation = false
  var lastLocationError: Error?
  
  // MARK: VIEW LIFE CYCLE
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //view.backgroundColor = .yellow
    updateLabels()
  }
  
  // MARK: ACTIONS
  
  @IBAction func getSpotPressed(_ sender: UIButton) {
    print("Get button pressed")
    let authStatus = locationManager.authorizationStatus
    if authStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    
    if authStatus == .denied || authStatus == .restricted {
      showLocationServicesDeniedAlert()
      return
    }
    
    if updatingLocation {
      stopLocationManager()
    } else {
      location = nil
      lastLocationError = nil
      startLocationManager()
    }
    updateLabels()
  }
    
    
    @IBAction func saveSpotPressed(_ sender: UIButton) {
        
        
    }
    
  
  // MARK: FUNCTIONS
  func updateLabels() {
    if let location = location {
      latitudeLabel.text = String(
        format: "%.8f",
        location.coordinate.latitude)
      longitudeLabel.text = String(
        format: "%.8f",
        location.coordinate.longitude)
      //tagButton.isHidden = false
      messageLabel.text = ""
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      //addressLabel.text = ""
      //tagButton.isHidden = true
      let statusMessage: String
          if let error = lastLocationError as NSError? {
            if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
              statusMessage = "Location Services Disabled"
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
  
  func configureGetButton() {
    if updatingLocation {
      getSpot.setTitle("Stop", for: .normal)
    } else {
      getSpot.setTitle("Get My Location", for: .normal)
    }
  }
  
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      updatingLocation = true
    }
  }
  
  func stopLocationManager() {
    if updatingLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
    }
  }
  
  // MARK: LOCATION MANAGER FUNCTIONS
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError \(error.localizedDescription)")
    
    if (error as NSError).code == CLError.locationUnknown.rawValue {
        return
    }
      lastLocationError = error
      stopLocationManager()
      updateLabels()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      let newLocation = locations.last!
      print("didUpdateLocations \(newLocation)")

      if newLocation.timestamp.timeIntervalSinceNow < -5 {
        return
      }

      if newLocation.horizontalAccuracy < 0 {
        return
      }

      if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {

        lastLocationError = nil
        location = newLocation

        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
          print("*** We're done!")
          stopLocationManager()
        }
        updateLabels()
      }
  }
  
  // MARK: - Helper Methods
  func showLocationServicesDeniedAlert() {
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
  
}

