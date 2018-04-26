//
//  CategoryTableViewController.swift
//  gradekeep
//
//  Created by Lee Angioletti on 4/25/18.
//  Copyright © 2018 Lee Angioletti. All rights reserved.
//

import UIKit
import Firebase

class CategoryTableViewController: UITableViewController {

    var categories: [[String : Any]] = []
    var ref: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set up categories listener
        let db = Firestore.firestore()
        db.collection(ref!).order(by: "catname")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                self.categories.removeAll()
                var sum = 0.0
                var weightsum = 0.0
                
                for document in documents {
                    let category = [
                        "catid" : document.documentID,
                        "catname" : document.data()["catname"],
                        "catgrade" : document.data()["catgrade"],
                        "weight" : document.data()["weight"]
                    ]
                    self.categories.append(category)
                    
                    sum += (0.1 * Double((category["weight"] as? Double)!) * Double((category["catgrade"] as? Double)!))
                    weightsum += (category["weight"])! as! Double
                }
                
                let index = self.ref?.index((self.ref?.startIndex)!, offsetBy: (self.ref?.count)! - 12)
                var cgrade = Double(round(1000*(sum / weightsum)) / 100)
                
                if (sum == 0.0) { cgrade = 0.0 }
                
                db.document((self.ref?.substring(to: index!))!).updateData([
                    "cgrade": cgrade
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
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        let catNameLabel = cell.viewWithTag(1) as! UILabel
        catNameLabel.text = categories[indexPath.row]["catname"] as? String
        
        let catGradeLabel = cell.viewWithTag(2) as! UILabel
        let x = categories[indexPath.row]["catgrade"] as? Double
        catGradeLabel.text = "\(x!)" + "%"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let db = Firestore.firestore()
            print(ref! + String(categories[indexPath.row]["catid"]! as! String))
            db.document(ref! + String(categories[indexPath.row]["catid"]! as! String)).delete() { err in
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
        case "newcatsegue":
            let nc = segue.destination as! UINavigationController
            let nextViewController = nc.topViewController as? NewCatTableViewController
            nextViewController?.ref = ref
        case "asssegue":
            let nextViewController = segue.destination as? AssignmentTableViewController
            let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            nextViewController?.navigationItem.title = categories[selectedIndex!]["catname"] as? String
            nextViewController?.ref = ref! + String(categories[selectedIndex!]["catid"]! as! String)+"/assignments/"
        default:
            break
        }
    }
}
