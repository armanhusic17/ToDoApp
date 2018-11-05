//
//  TableViewController.swift
//  690_Assignment2
//
//  Created by Arman Husic on 10/23/18.
//  Copyright © 2018 Arman Husic. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController    {
    
    var resultsController: NSFetchedResultsController<Todo>!
    let coreDataStack = CoreDataStacK()
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    
        
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptors]
            
            
        resultsController = NSFetchedResultsController(fetchRequest: request,
                                                       managedObjectContext: coreDataStack.managedContext,
                                                       sectionNameKeyPath: nil,
                                                       cacheName: nil)
        resultsController.delegate = self
        
        do {
        try resultsController.performFetch()
        } catch{
            print("Perform Fetch Error : \(error)")
        }
        
        
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        
        let todo01 = resultsController.object(at: indexPath)
        cell.textLabel?.text = todo01.title
        
        
        
        return cell
    }
    
    
    
    //Swiping Delete To Do
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            //get todo and delete it
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("delete failed: \(error)")
                completion(false)
            }
        }
        
        
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    
    
    //Swipe Complete To Do
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        let todo = self.resultsController.object(at: indexPath)
        
        let action = UIContextualAction(style: .normal, title: "Complete") { (action, nil, completion) in
            //checkmark todo
            //
            if todo.priority == 0 {
                cell.accessoryType = UITableViewCell.AccessoryType.none
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
                //UserDefaults.standard.set(UITableViewCell.AccessoryType.checkmark, forKey: "ToDoCell99")
            } else if todo.priority == 1 {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            }
            do {
                try self.resultsController.managedObjectContext.save()
          
                completion(true)
            } catch {
                print("complete failed: \(error)")
                completion(false)
            }
        }
        action.backgroundColor = .green
        performSegue(withIdentifier: "showAddToDo", sender: tableView.cellForRow(at: indexPath))
        return UISwipeActionsConfiguration(actions: [action])
    }
    
//    override func viewDidAppear(_ animated: Bool) {
// 
//            UserDefaults.standard.set(UITableViewCell.AccessoryType.checkmark, forKey: "ToDoCell99")
//            
//    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let todo = self.resultsController.object(at: indexPath)
        
        
        if todo.priority == 0 {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            performSegue(withIdentifier: "showAddToDo", sender: tableView.cellForRow(at: indexPath))
            
        }
   
    }
   
  
    
    
    //Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddToDoViewController {
            vc.managedContext = resultsController.managedObjectContext
        }
        
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddToDoViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell) {
                let todo = resultsController.object(at: indexPath)
                vc.todo = todo
            }
        }
        
     }
 
    
    
    
}


extension TableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let todo = resultsController.object(at: indexPath)
                cell.textLabel?.text = todo.title
            }
        default:
            break
        }
    }
}
