import Foundation
import UIKit

class SavedTrailsDetailsVC: UIViewController, UINavigationControllerDelegate {
  
  // MARK: PROPERTIES
  var run = [Run]()

  var noteData: Run! {
      didSet {
        distanceLabel.text = String(noteData.distance)
        durationLabel.text = String(noteData.duration)
        //dateLabel.text = dateFormatter.string(from: noteData.date ?? Date())
      }
  }
  
//  let dateFormatter: DateFormatter = {
//      let dateFormatter = DateFormatter()
//      dateFormatter.dateFormat = "MMMM dd, YYYY hh:mm"
//      return dateFormatter
//  }()
  
  fileprivate lazy var dateLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
      label.textColor = .black
      //label.text = dateFormatter.string(from: Date())
      label.text = "HELLO HELLO 3"
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
