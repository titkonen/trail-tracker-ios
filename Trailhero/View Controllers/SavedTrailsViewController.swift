import UIKit
import CoreData

class SavedTrailsViewController: UITableViewController {

  // MARK: Properties
  var run = [Run]()
  fileprivate let CustomCell:String = "CustomCell"
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // Context Layer
  
  lazy var paivaMuotoon: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()
  
  // MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTrails()
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
    
    // MARK: CRUD Functions
    func loadTrails() {
        
        let request : NSFetchRequest<Run> = Run.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Run.timestamp), ascending: false)
        request.sortDescriptors = [sortDescriptor]
      
        do {
          //run = try CoreDataStack.context.fetch(request)
          run = try context.fetch(request)
        } catch {
            print("Error Fetching data from context \(error)")
        }
        tableView.reloadData()
    }
  

} // End of main class
