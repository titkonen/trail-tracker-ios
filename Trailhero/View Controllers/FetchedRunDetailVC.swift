import UIKit
import MapKit

class FetchedRunDetailVC: UIViewController {
  
  // MARK: Outlets
//  @IBOutlet weak var dateLabel: UILabel!
//  @IBOutlet weak var durationLabel: UILabel!
//  @IBOutlet weak var distanceLabel: UILabel!
//  @IBOutlet weak var trainingNotes: UITextView!
  
  // MARK: Properties
  var run: Run!
  
  var runData: Run! {
      didSet {
        distanceLabel.text = String(format: "%.1f", runData.distance) + " m"
        durationLabel.text = String(runData.duration) + " sec"
        dateLabel.text = dateFormatter.string(from: runData.timestamp ?? Date())
        
        mapPoints.text = String(format: "%.1f",runData.locations!)
      }
  }
  
  let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, YYYY hh:mm"
        return dateFormatter
  }()
  
  // MARK: Prototyping Fetching the MapPoints
  fileprivate lazy var mapPoints: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
      label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
      label.text = "mapPoints..."
      label.textAlignment = .left
      return label
  }()
  
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
  }()
  
  // MARK: UI Properties
  fileprivate lazy var dateLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
      label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
      label.text = dateFormatter.string(from: runData.timestamp ?? Date())
      //label.text = "HELLO HELLO 3"
      label.textAlignment = .center
      return label
  }()
  
  fileprivate lazy var distanceLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
      label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
      label.text = "Distance..."
      label.textAlignment = .left
      return label
  }()
  
  fileprivate lazy var durationLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
      label.textColor = UIColor(red: 242/255, green: 224/255, blue: 201/255, alpha: 1)
      label.text = "Duration..."
      label.textAlignment = .left
      return label
  }()
  
  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    print("viewDidLoad is loaded")
    //view.backgroundColor = .orange
    setupUI()
    loadMap()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("viewDidAppear is loaded")
    
  }
  
  // MARK: Functions
  fileprivate func setupUI() {
      view.addSubview(dateLabel)
      view.addSubview(distanceLabel)
      view.addSubview(durationLabel)
      view.addSubview(mapPoints)
      view.addSubview(mapView)

      dateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
      dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
      dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

      distanceLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 140).isActive = true
      distanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
      distanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
      distanceLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -640).isActive = true

      durationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 180).isActive = true
      durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
      durationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
      durationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -600).isActive = true
    
      mapPoints.topAnchor.constraint(equalTo: view.topAnchor, constant: 220).isActive = true
      mapPoints.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
      mapPoints.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
      mapPoints.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -580).isActive = true
  }
  
  // MARK: MAP FUNCTIONS
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
    
    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                        longitude: (minLong + maxLong) / 2)
    let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                longitudeDelta: (maxLong - minLong) * 1.3)
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
      segment.color = segmentColor(speed: speed,
                                   midSpeed: midSpeed,
                                   slowestSpeed: minSpeed,
                                   fastestSpeed: maxSpeed)
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
        let alert = UIAlertController(title: "Error",
                                      message: "Sorry, this run has no locations saved",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
        return
    }
    
    mapView.setRegion(region, animated: true)
    mapView.addOverlays(polyLine())
    //mapView.addAnnotations(annotations())
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
  
}

// MARK: - Map View Delegate
extension FetchedRunDetailVC: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MulticolorPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = polyline.color
    renderer.lineWidth = 3
    return renderer
  }
}
