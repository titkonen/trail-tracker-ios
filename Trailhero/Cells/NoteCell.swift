import UIKit
import CoreLocation
import MapKit

class NoteCell: UITableViewCell {
  
  // MARK: PROPERTIES
  private var run: Run?
  private let locationManager = LocationManager.shared
  private var locationList: [CLLocation] = []
  private var distance = Measurement(value: 0, unit: UnitLength.meters)
  
  // MARK: DIDSETS
  var noteData: Run! {
        didSet {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "MM/dd/yy hh:mm"
          dateLabel.text = dateFormatter.string(from: noteData.timestamp ?? Date())
          noteTitle.text = String(format: "%.1f",noteData.distance) + " m"
          previewLabel.text = String(noteData.duration) + " sec"
        }
  }
  
  var paikkaTieto: Location! {
    didSet {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MM/dd/yy hh:mm"
      dateLabelLocation.text = dateFormatter.string(from: paikkaTieto.timestamp ?? Date())
      //print(paikkaTieto)
      latitudeLabel.text = String(paikkaTieto.latitude) + "lat..."
    }
  }
    
  //MARK: Location UI Properties
  /// Date label location
  fileprivate var dateLabelLocation: UILabel = {
      let label = UILabel()
      label.text = "Location dateLabel placeholder"
      label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
      label.textColor = UIColor.white.withAlphaComponent(0.5)
      return label
  }()
  
  /// Note title
  fileprivate var latitudeLabel: UILabel = {
      let label = UILabel()
      label.text = "Lat. placeholder"
      label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
      label.textColor = .white
      return label
  }()


  //MARK: Tracking UI Properties
    /// Note title
    fileprivate var noteTitle: UILabel = {
        let label = UILabel()
        label.text = "Places to take photos"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }()

    /// Date label
    fileprivate var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "4/6/2019"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
  
    /// Preview label
    fileprivate var previewLabel: UILabel = {
        let label = UILabel()
        label.text = "The note text will go here for note preview..."
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        //label.textColor = UIColor.gray.withAlphaComponent(0.8)
        return label
    }()
    
    /// horizontal stack view
    fileprivate lazy var horizontalStackView: UIStackView = {
        let s = UIStackView(arrangedSubviews: [noteTitle, previewLabel, latitudeLabel, UIView()])
        s.axis = .horizontal
        s.spacing = 20
        s.alignment = .leading
        return s
    }()
    
    /// vertical stack view
    fileprivate lazy var verticalStackView: UIStackView = {
        let s = UIStackView(arrangedSubviews: [dateLabel, dateLabelLocation, horizontalStackView])
        s.axis = .vertical
        s.spacing = 5
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(red: 2/255, green: 89/255, blue: 89/255, alpha: 1)
        contentView.addSubview(verticalStackView)
        verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        verticalStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: - Location Manager Delegate
extension NoteCell: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for newLocation in locations {
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
      
      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        //mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
        let region = MKCoordinateRegion.init(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        //mapView.setRegion(region, animated: true)
      }
      
      locationList.append(newLocation)
    }
  }
}

// MARK: - Map View Delegate
extension NoteCell: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .blue
    renderer.lineWidth = 3
    return renderer
  }
}
