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
    
    var ref: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addCatPressed(_ sender: Any) {
        let db = Firestore.firestore()
        
        let cat = [
            "catname" : catnameTextField.text,
            "catgrade" : 0.0,
            "weight" : Double(weightTextField.text!)
        ] as [String : Any]
        
        db.collection(ref!).addDocument(data: cat){ err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
