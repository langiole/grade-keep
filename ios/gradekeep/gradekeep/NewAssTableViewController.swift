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
    
    var ref: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addAssPressed(_ sender: Any) {
        let db = Firestore.firestore()
        
        let assname = assnameTextField.text
        let credit = Double(creditTextField.text!)
        let totalcredit = Int(totalcreditTextField.text!)

        let assignment = [
            "assname" : assname,
            "credit" : credit,
            "totalcredit" : totalcredit,
            "assgrade" : Double( round( 10000 * ( credit! / Double( totalcredit! ) ) ) / 100 )
        ] as [String : Any]
        
        db.collection(ref!).addDocument(data: assignment){ err in
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
