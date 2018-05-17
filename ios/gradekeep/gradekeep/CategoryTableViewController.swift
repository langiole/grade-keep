//
//  CategoryTableViewController.swift
//  gradekeep
//
//  Created by Lee Angioletti on 4/25/18.
//  Copyright © 2018 Lee Angioletti. All rights reserved.
//

import UIKit
import Firebase

enum Cat : String {
    case id
    case name = "catname"
    case grade = "catgrade"
    case weight
}

class CategoryTableViewController: UITableViewController {

    var categories: [[Cat : Any]] = []
    var ref: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set up categories listener
        let db = Firestore.firestore()
        db.collection(ref!).order(by: Cat.name.rawValue)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                // reset categories array
                self.categories.removeAll()
                var sum = 0.0
                var weightsum = 0.0
                
                // loop through documents
                for document in documents {
                    let category = [
                        Cat.id : document.documentID,
                        Cat.name : document.data()[Cat.name.rawValue] ?? "",
                        Cat.grade : document.data()[Cat.grade.rawValue] ?? 0.0,
                        Cat.weight : document.data()[Cat.weight.rawValue] ?? 0.0,
                    ]
                    self.categories.append(category)
                    
                    // calculations to find course grade
                    if (category[Cat.id]! == nil || category[Cat.name]! == nil ||
                        category[Cat.grade]! == nil || category[Cat.weight]! == nil) { print("ERROR: nil value in obj category") }
                    
                    sum += (0.1 * (category[Cat.weight] as! Double) * (category[Cat.grade] as! Double))
                    weightsum += category[Cat.weight] as! Double
                }
                
                // reload table
                self.tableView.reloadData()
                
                // update course grade in the background
                // substring ref & calculate course grade
                let index = self.ref?.index((self.ref?.startIndex)!, offsetBy: (self.ref?.count)! - 12)
                var cgrade = Double(round(1000*(sum / weightsum)) / 100)
                
                // course grade is 0 if there are no grades
                if (sum == 0.0) { cgrade = 0.0 }
                
                // update course grade
                db.document((self.ref?.substring(to: index!))!).updateData([
                    "cgrade": cgrade
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return categories.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let i = indexPath.row
        
        let catNameLabel = cell.viewWithTag(1) as! UILabel
        catNameLabel.text = categories[i][Cat.name] as? String
        
        let catGradeLabel = cell.viewWithTag(2) as! UILabel
        let x = categories[i][Cat.grade] as? Double
        catGradeLabel.text = "\(x!)" + "%"
        
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
            self.performSegue(withIdentifier: "editcatsegue", sender: self.tableView.cellForRow(at: index))
            completion(true)
        }
        action.title = "Edit"
        action.backgroundColor = UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0)
        return action
    }
    
    func deleteAction(at index: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let db = Firestore.firestore()
            db.document(self.ref! + String(self.categories[index.row][Cat.id]! as! String)).delete() { err in
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
        case "newcatsegue":
            let nextView = segue.destination as! UINavigationController
            let catView = nextView.topViewController as? NewCatTableViewController
            catView?.ref = ref
            catView?.mode = .new
        case "editcatsegue":
            let i = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let nextView = segue.destination as! UINavigationController
            let catView = nextView.topViewController as? NewCatTableViewController
            catView?.ref = ref! + String(categories[i!][Cat.id]! as! String)
            catView?.mode = .edit
            catView?.catnameFieldHolder = String(categories[i!][Cat.name]! as! String)
            catView?.weightFieldHolder = String(categories[i!][Cat.weight]! as! Double)
        case "asssegue":
            let i = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let assView = segue.destination as? AssignmentTableViewController
            assView?.navigationItem.title = categories[i!][Cat.name] as? String
            assView?.ref = ref! + String(categories[i!][Cat.id]! as! String) + "/assignments/"
        default:
            break
        }
    }
}
