//
//  CreateCourseTableViewController.swift
//  gradekeep
//
//  Created by Lee Angioletti on 4/26/18.
//  Copyright © 2018 Lee Angioletti. All rights reserved.
//

import UIKit
import Firebase

class NewCourseTableViewController: UITableViewController {
    
    @IBOutlet weak var cnameTextField: UITextField!
    var ref: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func addCoursePressed(_ sender: Any) {
        let db = Firestore.firestore()
        
        let course = [
            "cname" : cnameTextField.text,
            "cgrade" : 0.0
            ] as [String : Any]
        
        db.collection(ref!).addDocument(data: course){ err in
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
