//
//  AssignmentTableViewController.swift
//  gradekeep
//
//  Created by Lee Angioletti on 4/26/18.
//  Copyright © 2018 Lee Angioletti. All rights reserved.
//

import UIKit
import Firebase

enum Ass : String {
    case id
    case name = "assname"
    case credit
    case totalcredit
    case grade = "assgrade"
}

class AssignmentTableViewController: UITableViewController {

    var assignments: [[Ass : Any]] = []
    var ref: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init assignments listener and import data
        let db = Firestore.firestore()
        db.collection(ref!).order(by: Ass.name.rawValue)
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
                        Ass.id : document.documentID,
                        Ass.name : document.data()[Ass.name.rawValue] ?? "",
                        Ass.credit : document.data()[Ass.credit.rawValue] ?? 0.0,
                        Ass.totalcredit : document.data()[Ass.totalcredit.rawValue] ?? 1.0,
                        Ass.grade : document.data()[Ass.grade.rawValue] ?? 0.0,
                    ]
                    self.assignments.append(assignment)
                    
                    creditsum += (assignment[Ass.credit] as? Double)!
                    totalcreditsum += (assignment[Ass.totalcredit] as? Double)!
                }
                
                let index = self.ref?.index((self.ref?.startIndex)!, offsetBy: (self.ref?.count)! - 12)
                var catgrade = Double(round(10000*(creditsum / totalcreditsum)) / 100)
                
                if (creditsum == 0.0) { catgrade = 0.0 }

                db.document((self.ref?.substring(to: index!))!).updateData([
                    Cat.grade.rawValue : catgrade
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
        assNameLabel.text = assignments[indexPath.row][Ass.name] as? String
        
        let creditLabel = cell.viewWithTag(3) as! UILabel
        let x = assignments[indexPath.row][Ass.credit] as? Double
        creditLabel.text = "\(x!)"
        
        let totalcreditLabel = cell.viewWithTag(4) as! UILabel
        let y = assignments[indexPath.row][Ass.totalcredit] as? Double
        totalcreditLabel.text = "/\(y!)"
        
        let assGradeLabel = cell.viewWithTag(2) as! UILabel
        let z = assignments[indexPath.row][Ass.grade] as? Double
        assGradeLabel.text = "\(z!)" + "%"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func editAction(at index: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.performSegue(withIdentifier: "editasssegue", sender: self.tableView.cellForRow(at: index))
            completion(true)
        }
        action.title = "Edit"
        action.backgroundColor = UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0)
        return action
    }
    
    func deleteAction(at index: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let db = Firestore.firestore()
            db.document(self.ref! + String(self.assignments[index.row][Ass.id]! as! String)).delete() { err in
                if let err = err { print("Error removing document: \(err)") }
                else { print("Document successfully removed!") }
            }
            completion(true)
        }
        action.title = "Delete"
        action.backgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        return action
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "newasssegue":
            let nextView = segue.destination as! UINavigationController
            let assView = nextView.topViewController as? NewAssTableViewController
            assView?.ref = ref
            assView?.mode = .new
        case "editasssegue":
            let i = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let nextView = segue.destination as! UINavigationController
            let assView = nextView.topViewController as? NewAssTableViewController
            assView?.ref = ref! + String(assignments[i!][Ass.id]! as! String)
            assView?.mode = .edit
            assView?.assnameHolder = String(assignments[i!][Ass.name]! as! String)
            assView?.creditHolder = String(assignments[i!][Ass.credit]! as! Double)
            assView?.totalcreditHolder = String(assignments[i!][Ass.totalcredit]! as! Double)
        default:
            break
        }
    }
}
