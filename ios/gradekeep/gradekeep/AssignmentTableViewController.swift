//
//  AssignmentTableViewController.swift
//  gradekeep
//
//  Created by Lee Angioletti on 4/26/18.
//  Copyright © 2018 Lee Angioletti. All rights reserved.
//

import UIKit
import Firebase

class AssignmentTableViewController: UITableViewController {

    var assignments: [[String : Any]] = []
    var ref: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init assignments listener and import data
        let db = Firestore.firestore()
        db.collection(ref!).order(by: "assname")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                self.assignments.removeAll()
                var creditsum = 0.0
                var totalcreditsum = 0.0
                for document in documents {
                    let assignment = [
                        "assid" : document.documentID,
                        "assname" : document.data()["assname"],
                        "credit" : document.data()["credit"],
                        "totalcredit" : document.data()["totalcredit"],
                        "assgrade" : document.data()["assgrade"]
                    ]
                    self.assignments.append(assignment)
                    
                    creditsum += (assignment["credit"] as? Double)!
                    totalcreditsum += (assignment["totalcredit"] as? Double)!
                }
                
                let index = self.ref?.index((self.ref?.startIndex)!, offsetBy: (self.ref?.count)! - 12)
                let catgrade = Double(round(10000*(creditsum / totalcreditsum)) / 100)
                
                db.document((self.ref?.substring(to: index!))!).updateData([
                    "catgrade": catgrade
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }

                
                self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return assignments.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        // Configure the cell...
        let assNameLabel = cell.viewWithTag(1) as! UILabel
        assNameLabel.text = assignments[indexPath.row]["assname"] as? String
        
        let creditLabel = cell.viewWithTag(3) as! UILabel
        let x = assignments[indexPath.row]["credit"] as? Double
        creditLabel.text = "\(x!)"
        
        let totalcreditLabel = cell.viewWithTag(4) as! UILabel
        let y = assignments[indexPath.row]["totalcredit"] as? Double
        totalcreditLabel.text = "\(y!)"
        
        let assGradeLabel = cell.viewWithTag(2) as! UILabel
        let z = assignments[indexPath.row]["assgrade"] as? Double
        assGradeLabel.text = "\(z!)" + "%"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let db = Firestore.firestore()
            db.document(ref! + String(assignments[indexPath.row]["assid"]! as! String)).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "newasssegue":
            let nc = segue.destination as! UINavigationController
            let nextViewController = nc.topViewController as? NewAssTableViewController
            nextViewController?.ref = ref
        default:
            break
        }
    }
}
