import UIKit
import CoreData

class SavedTrailsViewController: UITableViewController {

  // MARK: - Properties
  var run = [Run]()

  fileprivate let CustomCell:String = "CustomCell"
  
  lazy var paivaMuotoon: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()
  
  var managedObjectContext: NSManagedObjectContext!
  
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // Context Layer
    
  // MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

    }
  
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
//      view.backgroundColor = .blue
//      print("viewWillAppear is red")
      
     // loadTrails()
      setupTableView()
      
    }
  
    // MARK: FUNCTIONS
    fileprivate func setupTableView() {
        tableView.register(NoteCell.self, forCellReuseIdentifier: CustomCell)
    }

    // MARK: TABLE VIEW DATA SOURCE

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return run.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! NoteCell ///Casting =>  as! NoteCell  to custom cell  //SavedTrailsCell
        //let walkDate = paivat[indexPath.row]
      
//        guard let kavely = run[indexPath.row] as? Run,
//          let walkDate = kavely.timestamp as Date? else {
//            return cell
//        }
      
//        cell.textLabel?.text = String(run[indexPath.row].distance)
//        cell.detailTextLabel?.text = paivaMuotoon.string(from: walkDate)
        //cell.textLabel?.text = savedtrails[indexPath.row].title
        //cell.detailTextLabel?.text = String(trails[indexPath.row].duration)
      
//      let lahetysLahtee = self.filteredRuns[indexPath.row]
//      cell.noteData = lahetysLahtee
      let noteForRow = self.run[indexPath.row]
      cell.noteData = noteForRow
      
      return cell
    }
  
    ///Push content to DetailController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let noteDetailController = SavedTrailsDetailsVC()
      let noteForRow = self.run[indexPath.row]
      noteDetailController.noteData = noteForRow
      
      navigationController?.pushViewController(noteDetailController, animated: true)
    }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      run.remove(at: indexPath.row)
      
      let indexPaths = [indexPath]
      tableView.deleteRows(at: indexPaths, with: .automatic)
    }
  
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - CRUD Functions
    
//    func saveTrails() {
//
//         do {
//            try context.save()
//         } catch {
//            print("Error saving context \(error)")
//         }
//         tableView.reloadData()
//    }
    
    /* func loadTrails() {
        
        let request : NSFetchRequest<Run> = Run.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Run.timestamp), ascending: false)
        request.sortDescriptors = [sortDescriptor]
      
        do {
          run = try context.fetch(request)
        } catch {
            print("Error Fetching data from context \(error)")
        }
        tableView.reloadData()
    } */
  

} // End of main class
