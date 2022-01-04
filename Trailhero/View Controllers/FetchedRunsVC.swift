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
    if let sections = fetchedResultsController.sections {
      return sections.count
    }
    return 0
    //OLD return fetchedResultsController.sections?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let sections = fetchedResultsController.sections {
      return sections[section].numberOfObjects
    }
    return 0
//    OLD
//    guard let sectionInfo = fetchedResultsController.sections?[section] else {
//        return 0
//    }
//    return sectionInfo.numberOfObjects
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
  
  ///Push content to Detail View FetchedRunDetailVC
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("tapped")
    let noteDetailController = FetchedRunDetailVC()
//    let noteForRow = self.run[indexPath.row]
//    noteDetailController.runData = noteForRow

    let location = fetchedResultsController.object(at: indexPath)
    noteDetailController.runData = location
    
    navigationController?.pushViewController(noteDetailController, animated: true)
  }

  
}

// MARK: - NSFetchedResultsControllerDelegate
extension FetchedRunsVC: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print("*** controllerWillChangeContent")
    tableView.beginUpdates()
  }
  
  /// This is v1 solution which works
//  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//    print("NSFetchedResultsControllerDelegate controllerDidChangeContent")
//      tableView.reloadData()
//  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      print("*** NSFetchedResultsChangeInsert (object)")
      tableView.insertRows(at: [newIndexPath!], with: .fade)

    case .delete:
      print("*** NSFetchedResultsChangeDelete (object)")
      tableView.deleteRows(at: [indexPath!], with: .fade)

    case .update:
      print("*** NSFetchedResultsChangeUpdate (object)")
      if let cell = tableView.cellForRow(
        at: indexPath!) as? FetchedRunsCell {
        let noteForRow = controller.object(
          at: indexPath!) as! Run
        cell.runData = noteForRow
      }

    case .move:
      print("*** NSFetchedResultsChangeMove (object)")
      tableView.deleteRows(at: [indexPath!], with: .fade)
      tableView.insertRows(at: [newIndexPath!], with: .fade)
      
    @unknown default:
      print("*** NSFetchedResults unknown type")
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      print("*** NSFetchedResultsChangeInsert (section)")
      tableView.insertSections(
        IndexSet(integer: sectionIndex), with: .fade)
    case .delete:
      print("*** NSFetchedResultsChangeDelete (section)")
      tableView.deleteSections(
        IndexSet(integer: sectionIndex), with: .fade)
    case .update:
      print("*** NSFetchedResultsChangeUpdate (section)")
    case .move:
      print("*** NSFetchedResultsChangeMove (section)")
    @unknown default:
      print("*** NSFetchedResults unknown type")
    }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print("*** controllerDidChangeContent")
    tableView.endUpdates()
  }
  
}


//// MARK: - Navigation

//extension FetchedRunsVC: SegueHandlerType {
//  enum SegueIdentifier: String {
//    case details = "RunDetailsViewController"
//  }
//
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    switch segueIdentifier(for: segue) {
//    case .details:
//      let destination = segue.destination as! RunDetailsViewController
//      let indexPath = tableView.indexPathForSelectedRow!
//      //destination.status = statusList[indexPath.row]
//      destination.run = run[indexPath.row]
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
