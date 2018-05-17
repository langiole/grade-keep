//
//  NewCatTableViewController.swift
//  gradekeep
//
//  Created by Lee Angioletti on 4/26/18.
//  Copyright © 2018 Lee Angioletti. All rights reserved.
//

import UIKit
import Firebase

class NewCatTableViewController: UITableViewController {
    
    @IBOutlet weak var catnameTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    var catnameFieldHolder = ""
    var weightFieldHolder = ""
    
    var mode = Mode.none
    
    var ref: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mode {
        case .new:
            self.navigationItem.title = "Add Category"
            confirmButton.setTitle("Add", for: .normal)
            confirmButton.isEnabled = false
        case .edit:
            self.navigationItem.title = "Update Category"
            confirmButton.setTitle("Update", for: .normal)
            confirmButton.isEnabled = false
            catnameTextField.text = catnameFieldHolder
            weightTextField.text = weightFieldHolder
        default:
            break
        }
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        // get the db
        let db = Firestore.firestore()
        
        let catname = catnameTextField.text
        let catgrade = 0.0
        let catweight = Double(weightTextField.text!)
        
        switch mode {
        case .new:
            // create new cat obj
            let category = [
                Cat.name.rawValue : catname ?? "",
                Cat.weight.rawValue : catweight ?? 0.0,
                Cat.grade.rawValue : catgrade,
            ] as [String : Any]
            
            // add doc to db
            db.collection(ref!).addDocument(data: category){ err in
                if let err = err { print("Error adding document: \(err)") }
                else { print("Document added") }
            }
        case .edit:
            // create new cat obj
            let category = [
                Cat.name.rawValue : catname ?? "",
                Cat.weight.rawValue : catweight ?? 0.0
            ] as [String : Any]
            
            // update doc in db
            db.document(ref!).updateData(category) { err in
                if let err = err { print("Error updating document: \(err)") }
                else { print("Document successfully updated") }
            }
        default:
            break
        }
        
        // dismiss the view
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editDidBegin(_ sender: UITextField) {
        if (textFieldsAreEmpty() || (mode == .edit && !textFieldsAreNew())) { self.confirmButton.isEnabled = false }
        else { self.confirmButton.isEnabled = true }
    }
    
    func textFieldsAreNew() -> Bool {
        return (catnameTextField.text == catnameFieldHolder && weightTextField.text == weightFieldHolder) ? false : true
    }
    
    func textFieldsAreEmpty() -> Bool {
        return (catnameTextField.text == "" || weightTextField.text == "") ? true : false
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
