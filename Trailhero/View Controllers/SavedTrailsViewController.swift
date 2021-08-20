import UIKit
import CoreData

class SavedTrailsViewController: UITableViewController {

  // MARK: - Properties
  //    var savedtrails = [Savedtrails]()
  var run = [Run]()
  //var paivat: [Date] = []
  
  lazy var paivaMuotoon: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()
  
    //let formattedDate = FormatDisplay.date(run.timestamp)
  
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // Context Layer
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTrails()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return run.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedTrailsCell", for: indexPath)
        //let walkDate = paivat[indexPath.row]
      
        guard let kavely = run[indexPath.row] as? Run,
          let walkDate = kavely.timestamp as Date? else {
            return cell
        }
      
        cell.textLabel?.text = String(run[indexPath.row].distance)
        //cell.detailTextLabel?.text = String(run[indexPath.row].distance)
      
        cell.detailTextLabel?.text = paivaMuotoon.string(from: walkDate)
        
        //cell.textLabel?.text = savedtrails[indexPath.row].title
        //cell.detailTextLabel?.text = String(trails[indexPath.row].duration)
        
        //let item = checklist.items[indexPath.row]
      
        return cell
    }
  
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      run.remove(at: indexPath.row)
      
      let indexPaths = [indexPath]
      tableView.deleteRows(at: indexPaths, with: .automatic)
    }
 

    // MARK: - Add New text
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
//        var textField = UITextField()
//        let alert = UIAlertController(title: "Add New text", message: "", preferredStyle: .alert)
//        let action = UIAlertAction(title: "Add", style: .default) { (action) in
//            let newTrails = Savedtrails(context: self.context)
//            newTrails.title = textField.text!
//            self.savedtrails.append(newTrails)
//            self.saveTrails()
//        }
//        alert.addAction(action)
//        alert.addTextField { (field) in
//            textField = field
//            textField.placeholder = "Add a new text"
//        }
//        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - CRUD Functions
    
    func saveTrails() {
         
         do {
            try context.save()
         } catch {
            print("Error saving context \(error)")
         }
         tableView.reloadData()
    }
    
    func loadTrails() {
        
        let request : NSFetchRequest<Run> = Run.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Run.timestamp), ascending: false)
        request.sortDescriptors = [sortDescriptor]
      
        do {
          run = try context.fetch(request)
        } catch {
            print("Error Fetching data from context \(error)")
        }
        tableView.reloadData()
    }

}

// MARK: - Navigation

extension SavedTrailsViewController: SegueHandlerType {
  enum SegueIdentifier: String {
    case details = "SavedTrailsDetailsVC"
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segueIdentifier(for: segue) {
    case .details:
      let destination = segue.destination as! SavedTrailsDetailsVC
      //destination.run = run
    }
  }
}


