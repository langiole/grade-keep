//
//  CourseTableViewController.swift
//  gradekeep
//
//  Created by Lee Angioletti on 4/25/18.
//  Copyright © 2018 Lee Angioletti. All rights reserved.
//

import UIKit
import Firebase

class CourseTableViewController: UITableViewController {

    var courses: [[String : Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up listener
        let db = Firestore.firestore()
        db.collection("users/aFor7zG6JZaFhtiNZrtcnUSCSNi1/courses")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                self.courses.removeAll()
                for document in documents {
                    self.courses.append(document.data())
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
        print("count:", courses.count)
        return courses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        let courseNameLabel = cell.viewWithTag(1) as! UILabel
        courseNameLabel.text = courses[indexPath.row]["cname"] as? String
        
        let courseGradeLabel = cell.viewWithTag(2) as! UILabel
        let x = courses[indexPath.row]["cgrade"] as? Double
        courseGradeLabel.text = "\(x!)" + "%"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? CategoryTableViewController {
            let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            viewControllerB.navigationItem.title = courses[selectedIndex!]["cname"] as? String
        }
    }
}
