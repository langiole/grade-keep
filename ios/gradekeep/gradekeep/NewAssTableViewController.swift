//
//  NewAssTableViewController.swift
//  gradekeep
//
//  Created by Lee Angioletti on 4/26/18.
//  Copyright © 2018 Lee Angioletti. All rights reserved.
//

import UIKit
import Firebase

class NewAssTableViewController: UITableViewController {

    @IBOutlet weak var assnameTextField: UITextField!
    @IBOutlet weak var creditTextField: UITextField!
    @IBOutlet weak var totalcreditTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    var assnameHolder = ""
    var creditHolder = ""
    var totalcreditHolder = ""
    
    var mode = Mode.none
    
    var ref: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mode {
        case .new:
            self.navigationItem.title = "Add Assignment"
            confirmButton.setTitle("Add", for: .normal)
            confirmButton.isEnabled = false
        case .edit:
            self.navigationItem.title = "Update Assignment"
            confirmButton.setTitle("Update", for: .normal)
            confirmButton.isEnabled = false
            assnameTextField.text = assnameHolder
            creditTextField.text = creditHolder
            totalcreditTextField.text = totalcreditHolder
        default:
            break
        }    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        // get the db
        let db = Firestore.firestore()
        
        let assname = assnameTextField.text
        let credit = Double(creditTextField.text!)
        let totalcredit = Double(totalcreditTextField.text!)
        
        // create new ass obj
        let assignment = [
            Ass.name.rawValue : assname ?? "",
            Ass.credit.rawValue : credit ?? 0.0,
            Ass.totalcredit.rawValue : totalcredit ?? 1.0,
            Ass.grade.rawValue : Double( round( 10000 * credit! / totalcredit! ) / 100 )
        ] as [String : Any]
        
        switch mode {
        case .new:
            // add doc to db
            db.collection(ref!).addDocument(data: assignment){ err in
                if let err = err { print("Error adding document: \(err)") }
                else { print("Document added") }
            }
        case .edit:
            // update doc in db
            db.document(ref!).updateData(assignment) { err in
                if let err = err { print("Error updating document: \(err)") }
                else { print("Document successfully updated") }
            }
        default:
            break
        }
        
        // dismiss the view
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editDidBegin(_ sender: Any) {
        if (textFieldsAreEmpty() || (mode == .edit && !textFieldsAreNew())) { self.confirmButton.isEnabled = false }
        else { self.confirmButton.isEnabled = true }
    }
    
    func textFieldsAreNew() -> Bool {
        return (assnameTextField.text == assnameHolder && creditTextField.text == creditHolder && totalcreditTextField.text == totalcreditHolder) ? false : true
    }
    
    func textFieldsAreEmpty() -> Bool {
        return (assnameTextField.text == "" || creditTextField.text == "" || totalcreditTextField.text == "") ? true : false
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
