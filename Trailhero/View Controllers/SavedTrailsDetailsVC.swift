import UIKit
import MapKit
import CoreLocation
import CoreData

class SavedTrailsDetailsVC: UIViewController, UINavigationControllerDelegate {
  
  // MARK: Outlets
  @IBOutlet weak var mapView: MKMapView!

  // MARK: TESTING
  private var paikat: Location!
  
  // MARK: Properties
  //var run = [Run]()
  //var run: Run!
  private var run: Run!
  private let locationManager = LocationManager.shared
  private var locationList: [CLLocation] = []
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // Context Layer
  
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
  
  var paikkaTieto: Location! {
    didSet {
      dateLabelLocation.text = dateFormatter.string(from: paikkaTieto.timestamp ?? Date())
      latitudeLabel.text = String(paikkaTieto.latitude) + "lat..."
    }
  }
  
  //MARK: Location UI Properties
  fileprivate lazy var dateLabelLocation: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
      label.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
      label.text = dateFormatter.string(from: noteData.timestamp ?? Date())
      //label.text = "HELLO dateLabel 3"
      label.textAlignment = .left
      return label
  }()
  
  fileprivate lazy var latitudeLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
      label.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
      label.text = "latitudeLabel placeholder"
      label.textAlignment = .right
      return label
  }()
  
  //MARK: Tracking UI Properties
  fileprivate lazy var dateLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
      label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
      label.text = dateFormatter.string(from: noteData.timestamp ?? Date())
      //label.text = "HELLO dateLabel 3"
      label.textAlignment = .left
      return label
  }()
  
  fileprivate lazy var distanceLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
      label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
      //label.text = dateFormatter.string(from: Date())
      label.text = "distanceLabel !!!"
      label.textAlignment = .left
      return label
  }()
  
  fileprivate lazy var durationLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
      label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
      //label.text = dateFormatter.string(from: Date())
      label.text = "durationLabel !!!"
      label.textAlignment = .right
      return label
  }()

  
  /*fileprivate lazy var mapView: MKMapView = {
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
    //loadLocations()
    lataaPaikkaObjekti()
    loadMap()
    
    print(noteData.distance)
//    print(paikkaTieto.latitude)
    print(noteData.timestamp)
    //print(paikkaTieto.timestamp ?? "test")
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
  
  /// Fetch locations from coredata
  /*private func loadLocations() -> [Run] {
      let fetchRequest: NSFetchRequest<Run> = Run.fetchRequest()
      let sortDescriptor = NSSortDescriptor(key: #keyPath(Run.timestamp), ascending: true)
      fetchRequest.sortDescriptors = [sortDescriptor]
      do {
        return try CoreDataStack.context.fetch(fetchRequest)
      } catch {
        return []
      }
    print("loadLocations...")
  } */
  
  private func lataaPaikkaObjekti() {
    for location in locationList {
      let locationObject = Location(context: CoreDataStack.context)
      locationObject.timestamp = location.timestamp
      locationObject.latitude = location.coordinate.latitude
      locationObject.longitude = location.coordinate.longitude
      print("Paikkaobjekti ladattu ...")
    }
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
    mapView.addAnnotations(annotations())
    print("loadMap loaded successfully")
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
  
  private func annotations() -> [BadgeAnnotation] {
    var annotations: [BadgeAnnotation] = []
    let badgesEarned = Badge.allBadges.filter { $0.distance < run.distance }
    var badgeIterator = badgesEarned.makeIterator()
    var nextBadge = badgeIterator.next()
    let locations = run.locations?.array as! [Location]
    var distance = 0.0
    
    for (first, second) in zip(locations, locations.dropFirst()) {
      guard let badge = nextBadge else { break }
      let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
      let end = CLLocation(latitude: second.latitude, longitude: second.longitude)
      distance += end.distance(from: start)
      if distance >= badge.distance {
        let badgeAnnotation = BadgeAnnotation(imageName: badge.imageName)
        badgeAnnotation.coordinate = end.coordinate
        badgeAnnotation.title = badge.name
        badgeAnnotation.subtitle = FormatDisplay.distance(badge.distance)
        annotations.append(badgeAnnotation)
        nextBadge = badgeIterator.next()
      }
    }
    
    return annotations
  }
  
  
  // MARK: UI
  fileprivate func setupUI() {
      view.addSubview(dateLabel)
      view.addSubview(distanceLabel)
      view.addSubview(durationLabel)
      //view.addSubview(mapView)
      view.addSubview(dateLabelLocation)
      view.addSubview(latitudeLabel)
      
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
    
    dateLabelLocation.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
    dateLabelLocation.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    dateLabelLocation.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

    latitudeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 240).isActive = true
    latitudeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    latitudeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
  }
  
}

// MARK: Location Manager Delegate
/*extension SavedTrailsDetailsVC: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for newLocation in locations {
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
      
      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
        let region = MKCoordinateRegion.init(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
      }
      
      locationList.append(newLocation)
    }
  }
}*/

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
  
 func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
  }
  
}
