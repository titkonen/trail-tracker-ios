import Foundation
import UIKit
import MapKit

//dateLabel.text = dateFormatter.string(from: noteData.timestamp ?? Date())

class SavedTrailsDetailsVC: UIViewController, UINavigationControllerDelegate {
  
  // MARK: PROPERTIES
  var run = [Run]()

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
      label.textColor = .black
      label.text = dateFormatter.string(from: noteData.timestamp ?? Date())
      //label.text = "HELLO HELLO 3"
      label.textAlignment = .center
      return label
  }()
  
  fileprivate lazy var distanceLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
      label.textColor = .black
      //label.text = dateFormatter.string(from: Date())
      label.text = "distance !!!"
      label.textAlignment = .center
      return label
  }()
  
  fileprivate lazy var durationLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
      label.textColor = .black
      //label.text = dateFormatter.string(from: Date())
      label.text = "distance !!!"
      label.textAlignment = .center
      return label
  }()
  
  fileprivate lazy var mapLabel: MKMapView = {
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
  
  // MARK: VIEW LIFE CYCLE
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .lightGray
    print("viewDidLoad is loaded")
    
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    view.backgroundColor = .white
    //print("viewWillAppear is loaded 2")
    
    distanceLabel.text = String(format: "%.1f", noteData.distance) + " m"
    durationLabel.text = String(noteData.duration) + " sec"
    //dateLabel?.text = "HELLO HELLO"
    
  }
  
  fileprivate func setupUI() {
      view.addSubview(dateLabel)
      view.addSubview(distanceLabel)
      view.addSubview(durationLabel)
      view.addSubview(mapLabel)
      
      dateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 90).isActive = true
      dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
      dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
      
      distanceLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 30).isActive = true
      distanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
      distanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
      distanceLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -640).isActive = true
    
      durationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
      durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
      durationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
      durationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -580).isActive = true
    
  }
  
}
