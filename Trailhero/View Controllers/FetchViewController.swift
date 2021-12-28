import UIKit
import CoreData
import CoreLocation

class FetchViewController: UITableViewController {
  
  // MARK: Outlets
  
  // MARK: Properties
  var managedObjectContext: NSManagedObjectContext!
  lazy var fetchedResultsController: NSFetchedResultsController<Run> = {
    let fetchRequest = NSFetchRequest<Run>()

    let entity = Run.entity()
    fetchRequest.entity = entity

    //let sort1 = NSSortDescriptor(key: "category", ascending: true)
    let sort2 = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sort2] ///sort1,
      
    fetchRequest.fetchBatchSize = 20

    let fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: self.managedObjectContext,
      sectionNameKeyPath: "date", /// category
      cacheName: "Locations")

    fetchedResultsController.delegate = self
    return fetchedResultsController
  }()
  
  
  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    performFetch()
    
    view.backgroundColor = .yellow
    
  }
  
  // MARK: Functions
  func performFetch() {
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Error: updating \(error)")
    }
  }
  
  deinit {
    fetchedResultsController.delegate = nil
  }
  
  // MARK: TableView Data Source?
  override func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections!.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = fetchedResultsController.sections![section]
    return sectionInfo.name
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 65
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "RunCell", for: indexPath) as! RunCell

      let location = fetchedResultsController.object(at: indexPath)
      cell.configure(for: location)

      return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let run = fetchedResultsController.object(at: indexPath)
      //run.removePhotoFile() ///Delete photoFile from the system.
      managedObjectContext.delete(run)
      
      do {
        try managedObjectContext.save()
      } catch {
          fatalError("Error: deleting \(error)")
      }
      
    }
  }
  
  // MARK: Navigation to the RunDetailsVC
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "EditLocation" {
      let controller = segue.destination  as! RunDetailsViewController
      controller.managedObjectContext = managedObjectContext

      if let indexPath = tableView.indexPath(
        for: sender as! UITableViewCell) {
        //let location = locations[indexPath.row]
        let location = fetchedResultsController.object(at: indexPath)
        controller.locationToEdit = location
      }
    }
  }
  
  
  
  
} ///End

// MARK: - NSFetchedResultsController Delegate Extension
extension FetchViewController: NSFetchedResultsControllerDelegate {
    
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print("*** controllerWillChangeContent")
    tableView.beginUpdates()
  }

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
        at: indexPath!) as? RunCell {
        let run = controller.object(
          at: indexPath!) as! Run
        cell.configure(for: run)
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

