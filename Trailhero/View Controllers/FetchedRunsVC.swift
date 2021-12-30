import UIKit
import CoreData

class FetchedRunsVC: UITableViewController {
  
  // MARK: Properties
  var run = [Run]()
  fileprivate let CustomCell:String = "CustomCell"
  //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // Context Layer

  // MARK: FetchResultController
  lazy var  coreDataStack = CoreDataStack(modelName: "MoonRunner")
  
  lazy var fetchedResultsController:
    NSFetchedResultsController<Run> = {
    let fetchRequest: NSFetchRequest<Run> = Run.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: #keyPath(Run.timestamp), ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]

    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: coreDataStack.managedContext,
      sectionNameKeyPath: nil,
      cacheName: nil)

    return fetchedResultsController
  }()

  
  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    //fetchRuns()
    setupTableView()
    
    //NS Fetching
    do {
      try fetchedResultsController.performFetch()
    } catch let error as NSError {
      print("Fetching error: \(error), \(error.userInfo)")
    }

  }
  
  // MARK: Functions
/*
  func fetchRuns() {
      let request : NSFetchRequest<Run> = Run.fetchRequest()
      let sortDescriptor = NSSortDescriptor(key: #keyPath(Run.timestamp), ascending: false)
      request.sortDescriptors = [sortDescriptor]
    
      do {
        run = try CoreDataStack.context.fetch(request)
        print("Load trails fetched 2")
      } catch {
          print("Error Fetching data from context \(error)")
      }
      tableView.reloadData()
  } */
  
  fileprivate func setupTableView() {
      tableView.register(FetchedRunsCell.self, forCellReuseIdentifier: CustomCell)
  }
  
  
} // end

// MARK: Table View Data Source
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

  /*
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return run.count
  }*/
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! FetchedRunsCell
    
    let noteForRow = fetchedResultsController.object(at: indexPath) /// fetchresult style
    
    //let noteForRow = self.run[indexPath.row] ///Earlier workable style
    cell.runData = noteForRow
    
    return cell
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
