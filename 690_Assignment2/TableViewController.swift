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
    
    //Swiping - Taken From Tutorial
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            //get todo and delete it
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
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Complete") { (action, view, completion) in
            
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
        
        action.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    
    //Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddToDoViewController {
            vc.managedContext = resultsController.managedObjectContext
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
        default:
            break
        }
    }
}
