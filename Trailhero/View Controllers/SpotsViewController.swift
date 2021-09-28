import UIKit
import CoreLocation

class SpotsViewController: UIViewController, CLLocationManagerDelegate {
  
  // MARK: OUTLETS
  @IBOutlet weak var spotsButton: UIBarButtonItem!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  
  // MARK: PROPERTIES
  var location: CLLocation? ///Storing the location
  let locationManager = CLLocationManager()
  
  // MARK: VIEW LIFE CYCLE
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //view.backgroundColor = .yellow
  }
  
  // MARK: ACTIONS
  @IBAction func addSpotsButtonPressed(_ sender: UIBarButtonItem) {
    print("Spot button pressed")
    let authStatus = locationManager.authorizationStatus
    if authStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    
    if authStatus == .denied || authStatus == .restricted {
      showLocationServicesDeniedAlert()
      return
    }
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.startUpdatingLocation()
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
      //messageLabel.text = ""
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      //addressLabel.text = ""
      //tagButton.isHidden = true
      //messageLabel.text = "Tap 'Get My Location' to Start"
    }
  }
  
  // MARK: LOCATION MANAGER FUNCTIONS
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError \(error.localizedDescription)")
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      let newLocation = locations.last!
      print("didUpdateLocations \(newLocation)")
      
      location = newLocation
      updateLabels()
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


