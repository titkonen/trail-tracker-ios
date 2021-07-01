import UIKit
import CoreData

class SavedTrailsViewController: UITableViewController {

//    var savedtrails = [Savedtrails]()
    var run = [Run]()
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
        
        cell.textLabel?.text = String(run[indexPath.row].duration)
        cell.detailTextLabel?.text = String(run[indexPath.row].distance)
        
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
        
        do {
          run = try context.fetch(request)
        } catch {
            print("Error Fetching data from context \(error)")
        }
        tableView.reloadData()
    }

    

   
}

// MARK: - Navigation

extension BadgesTableViewController: SegueHandlerType {
  enum SegueIdentifier: String {
    case details = "BadgeDetailsViewController"
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segueIdentifier(for: segue) {
    case .details:
      let destination = segue.destination as! BadgeDetailsViewController
      let indexPath = tableView.indexPathForSelectedRow!
      destination.status = statusList[indexPath.row]
    }
  }

  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    guard let segue = SegueIdentifier(rawValue: identifier) else { return false }
    switch segue {
    case .details:
      guard let cell = sender as? UITableViewCell else { return false }
      return cell.accessoryType == .disclosureIndicator
    }
  }
}
