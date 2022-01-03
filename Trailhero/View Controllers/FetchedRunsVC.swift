import UIKit
import CoreData

class FetchedRunsVC: UITableViewController {
  
  // MARK: Properties
  var run = [Run]()
  fileprivate let CustomCell:String = "CustomCell"

  // MARK: FetchResultController properties
  var managedObjectContext: NSManagedObjectContext!
  lazy var  coreDataStack = CoreDataStack(modelName: "MoonRunner")
  
  lazy var fetchedResultsController: NSFetchedResultsController<Run> = {
    let fetchRequest: NSFetchRequest<Run> = Run.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: #keyPath(Run.timestamp), ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]

    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: coreDataStack.managedContext,
      //managedObjectContext: self.managedObjectContext, ///test
      sectionNameKeyPath: #keyPath(Run.timestamp),
      cacheName: "trailhero")
      
      fetchedResultsController.delegate = self /// Sends to to extension delegate
    return fetchedResultsController
  }()

  
  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
   
    do {
      print("First time view loaded.")
      try fetchedResultsController.performFetch()
    } catch let error as NSError {
      print("Fetching error: \(error), \(error.userInfo)")
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    performFetch()
  }
  
  // MARK: Functions
  func performFetch() {
    do {
      tableView.reloadData()
      print("View updated.")
      try fetchedResultsController.performFetch()
    } catch let error as NSError {
      print("Fetching error: \(error), \(error.userInfo)")
    }
  }
  
  fileprivate func setupTableView() {
      tableView.register(FetchedRunsCell.self, forCellReuseIdentifier: CustomCell)
  }
  
} // end

// MARK: extension Table View Data Source
extension FetchedRunsVC {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sectionInfo = fetchedResultsController.sections?[section] else {
        return 0
    }
    return sectionInfo.numberOfObjects
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 64
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! FetchedRunsCell
    let noteForRow = fetchedResultsController.object(at: indexPath) /// fetchresult style
    cell.runData = noteForRow
    return cell
  }
  
  //Delete row
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

    // empty now
  }
  
  ///Push content to DetailController
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let noteDetailController = RunDetailsViewController()
    let noteForRow = self.run[indexPath.row]
    noteDetailController.runData = noteForRow
    
    navigationController?.pushViewController(noteDetailController, animated: true)
  }

  
}

// MARK: - NSFetchedResultsControllerDelegate
extension FetchedRunsVC: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print("NSFetchedResultsControllerDelegate controllerDidChangeContent")
      tableView.reloadData()
  }
}


//// MARK: - Navigation
//
//extension BadgesTableViewController: SegueHandlerType {
//  enum SegueIdentifier: String {
//    case details = "BadgeDetailsViewController"
//  }
//  
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    switch segueIdentifier(for: segue) {
//    case .details:
//      let destination = segue.destination as! BadgeDetailsViewController
//      let indexPath = tableView.indexPathForSelectedRow!
//      destination.status = statusList[indexPath.row]
//    }
//  }
//  
//  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//    guard let segue = SegueIdentifier(rawValue: identifier) else { return false }
//    switch segue {
//    case .details:
//      guard let cell = sender as? UITableViewCell else { return false }
//      return cell.accessoryType == .disclosureIndicator
//    }
//  }
//}
