import UIKit
//import MapKit

class FetchedRunDetailVC: UIViewController {
  
  // MARK: Outlets
//  @IBOutlet weak var dateLabel: UILabel!
//  @IBOutlet weak var durationLabel: UILabel!
//  @IBOutlet weak var distanceLabel: UILabel!
//  @IBOutlet weak var trainingNotes: UITextView!
  
  // MARK: Properties
  var runData: Run! {
      didSet {
        distanceLabel.text = String(format: "%.1f", runData.distance) + " m"
        durationLabel.text = String(runData.duration) + " sec"
        dateLabel.text = dateFormatter.string(from: runData.timestamp ?? Date())
        
        
      }
  }
  
  let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, YYYY hh:mm"
        return dateFormatter
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
  }
  
  
}

