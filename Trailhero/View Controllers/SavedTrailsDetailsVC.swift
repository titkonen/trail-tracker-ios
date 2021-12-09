import UIKit
import MapKit

class SavedTrailsDetailsVC: UIViewController, UINavigationControllerDelegate {
  
  // MARK: Outlets
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: Properties
  //var run = [Run]()
  var run: Run!

  let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, YYYY hh:mm"
        //dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter
  }()
    
  var noteData: Run! {
      didSet {
        distanceLabel.text = String(noteData.distance)
        durationLabel.text = String(noteData.duration)
        dateLabel.text = dateFormatter.string(from: noteData.timestamp ?? Date())
      }
  }
  
  fileprivate lazy var dateLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
      label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
      label.text = dateFormatter.string(from: noteData.timestamp ?? Date())
      //label.text = "HELLO HELLO 3"
      label.textAlignment = .left
      return label
  }()
  
  fileprivate lazy var distanceLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
      label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
      //label.text = dateFormatter.string(from: Date())
      label.text = "distance !!!"
      label.textAlignment = .left
      return label
  }()
  
  fileprivate lazy var durationLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
      label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
      //label.text = dateFormatter.string(from: Date())
      label.text = "distance !!!"
      label.textAlignment = .right
      return label
  }()

  /*
  fileprivate lazy var mapView: MKMapView = {
      let kartta = MKMapView()
      
      let leftMargin:CGFloat = 0
      let topMargin:CGFloat = 360
      let mapWidth:CGFloat = view.frame.size.width
      let mapHeight:CGFloat = view.frame.size.height
            
      kartta.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
      kartta.mapType = MKMapType.standard
      kartta.isZoomEnabled = true
      kartta.isScrollEnabled = true
    
      return kartta
  }()*/
  
  // MARK: VIEW LIFE CYCLE
  override func viewDidLoad() {
    super.viewDidLoad()
    print("viewDidLoad is loaded")
    setupUI()
    loadMap()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    view.backgroundColor = UIColor(red: 0/255, green: 59/255, blue: 59/255, alpha: 1)
    //print("viewWillAppear is loaded 2")
    distanceLabel.text = String(format: "%.1f", noteData.distance) + " m"
    durationLabel.text = String(noteData.duration) + " sec"
    //dateLabel?.text = "HELLO HELLO"
  }
  
  // MARK: Map functions
  private func mapRegion() -> MKCoordinateRegion? {
    guard
      let locations = run.locations,
      locations.count > 0
    else {
      return nil
    }
    
    let latitudes = locations.map { location -> Double in
      let location = location as! Location
      return location.latitude
    }
    
    let longitudes = locations.map { location -> Double in
      let location = location as! Location
      return location.longitude
    }
    
    let maxLat = latitudes.max()!
    let minLat = latitudes.min()!
    let maxLong = longitudes.max()!
    let minLong = longitudes.min()!
    
    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + maxLong) / 2)
    let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLong - minLong) * 1.3)
    return MKCoordinateRegion(center: center, span: span)
  }
  
  private func polyLine() -> [MulticolorPolyline] {
    
    let locations = run.locations?.array as! [Location]
    var coordinates: [(CLLocation, CLLocation)] = []
    var speeds: [Double] = []
    var minSpeed = Double.greatestFiniteMagnitude
    var maxSpeed = 0.0
    
    for (first, second) in zip(locations, locations.dropFirst()) {
      let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
      let end = CLLocation(latitude: second.latitude, longitude: second.longitude)
      coordinates.append((start, end))
      
      let distance = end.distance(from: start)
      let time = second.timestamp!.timeIntervalSince(first.timestamp! as Date)
      let speed = time > 0 ? distance / time : 0
      speeds.append(speed)
      minSpeed = min(minSpeed, speed)
      maxSpeed = max(maxSpeed, speed)
    }
    
    let midSpeed = speeds.reduce(0, +) / Double(speeds.count)
    
    var segments: [MulticolorPolyline] = []
    for ((start, end), speed) in zip(coordinates, speeds) {
      let coords = [start.coordinate, end.coordinate]
      let segment = MulticolorPolyline(coordinates: coords, count: 2)
      segment.color = segmentColor(speed: speed, midSpeed: midSpeed, slowestSpeed: minSpeed, fastestSpeed: maxSpeed)
      segments.append(segment)
    }
    return segments
  }
  
  private func loadMap() {
    guard
      let locations = run?.locations,
      locations.count > 0,
      let region = mapRegion()
    else {
        let alert = UIAlertController(title: "Error", message: "Sorry, this run has no locations saved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
        return
    }
    
    mapView.setRegion(region, animated: true)
    mapView.addOverlays(polyLine())
    //mapView.addAnnotations(annotations())
    print("loadMap loaded")
  }
  
  private func segmentColor(speed: Double, midSpeed: Double, slowestSpeed: Double, fastestSpeed: Double) -> UIColor {
    enum BaseColors {
      static let r_red: CGFloat = 1
      static let r_green: CGFloat = 20 / 255
      static let r_blue: CGFloat = 44 / 255
      
      static let y_red: CGFloat = 1
      static let y_green: CGFloat = 215 / 255
      static let y_blue: CGFloat = 0
      
      static let g_red: CGFloat = 0
      static let g_green: CGFloat = 146 / 255
      static let g_blue: CGFloat = 78 / 255
    }
    
    let red, green, blue: CGFloat
    
    if speed < midSpeed {
      let ratio = CGFloat((speed - slowestSpeed) / (midSpeed - slowestSpeed))
      red = BaseColors.r_red + ratio * (BaseColors.y_red - BaseColors.r_red)
      green = BaseColors.r_green + ratio * (BaseColors.y_green - BaseColors.r_green)
      blue = BaseColors.r_blue + ratio * (BaseColors.y_blue - BaseColors.r_blue)
    } else {
      let ratio = CGFloat((speed - midSpeed) / (fastestSpeed - midSpeed))
      red = BaseColors.y_red + ratio * (BaseColors.g_red - BaseColors.y_red)
      green = BaseColors.y_green + ratio * (BaseColors.g_green - BaseColors.y_green)
      blue = BaseColors.y_blue + ratio * (BaseColors.g_blue - BaseColors.y_blue)
    }
    
    return UIColor(red: red, green: green, blue: blue, alpha: 1)
  }
  
  
  // MARK: UI
  
  fileprivate func setupUI() {
      view.addSubview(dateLabel)
      view.addSubview(distanceLabel)
      view.addSubview(durationLabel)
      //view.addSubview(mapView)
      
      dateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
      dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
      dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
      
      distanceLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 140).isActive = true
      distanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
      distanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
      distanceLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -640).isActive = true
    
      durationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 140).isActive = true
      durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
      durationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
      durationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -640).isActive = true
    
  }
  
}

// MARK: Map View Delegate
extension SavedTrailsDetailsVC: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MulticolorPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = polyline.color
    renderer.lineWidth = 3
    return renderer
  }
  
 /* func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let annotation = annotation as? BadgeAnnotation else { return nil }
    let reuseID = "checkpoint"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
    if annotationView == nil {
      annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
      annotationView?.image = #imageLiteral(resourceName: "mapPin")
      annotationView?.canShowCallout = true
    }
    annotationView?.annotation = annotation
    
    let badgeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    badgeImageView.image = UIImage(named: annotation.imageName)
    badgeImageView.contentMode = .scaleAspectFit
    annotationView?.leftCalloutAccessoryView = badgeImageView
    
    return annotationView
  } */
  
}
