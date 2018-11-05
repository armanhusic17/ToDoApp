//
//  AddToDoViewController.swift
//  690_Assignment2
//
//  I followed a tutorial on youtube
//  credited to Gary Tokman.

import UIKit
import CoreData

class AddToDoViewController: UIViewController   {
    
    
    //adding properties
    var managedContext: NSManagedObjectContext!
    
    
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
          textView.becomeFirstResponder()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(with:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
      
        
    }
    
    
    @objc func keyboardWillShow(with notification: Notification) {
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else {return}
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        bottomConstraint.constant = keyboardHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
        textView.resignFirstResponder()
    }
    
    
    
    @IBAction func done(_ sender: UIButton) {
        guard let title = textView.text, !title.isEmpty else {
            //print("Error cant save empty todo...\(error)")
            return
        }
        
        let todo = Todo(context: managedContext)
        
        todo.title = title
        todo.priority = Int16(segmentedControl.selectedSegmentIndex)
        todo.date = Date()
        
        do {
            try managedContext.save()
            dismiss(animated: true)
            textView.resignFirstResponder()
        } catch{
            print("Error Saving todo : \(error)")
        }
        
    }
    
    
    
    
    
}


extension AddToDoViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if doneButton.isHidden {
            textView.text.removeAll()
            textView.textColor = .white
            
            doneButton.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
    }
}
