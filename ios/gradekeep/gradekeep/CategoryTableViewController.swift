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
        db.collection(ref!)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                self.categories.removeAll()
                for document in documents {
                    let category = [
                        "catid" : document.documentID,
                        "catname" : document.data()["catname"],
                        "catgrade" : document.data()["catgrade"],
                        "weight" : document.data()["weight"]
                    ]
                    self.categories.append(category)
                }
                self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "newcatsegue":
            let nc = segue.destination as! UINavigationController
            let nextViewController = nc.topViewController as? NewCatTableViewController
            nextViewController?.ref = ref
        default:
            break
        }
    }
}
