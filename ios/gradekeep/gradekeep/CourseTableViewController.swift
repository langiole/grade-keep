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
    let uid = "aFor7zG6JZaFhtiNZrtcnUSCSNi1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up courses listener
        let db = Firestore.firestore()
        db.collection("users/aFor7zG6JZaFhtiNZrtcnUSCSNi1/courses").order(by: "cname")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                self.courses.removeAll()
                for document in documents {
                    let course = [
                        "cid" : document.documentID,
                        "cname" : document.data()["cname"],
                        "cgrade" : document.data()["cgrade"]
                    ]
                    self.courses.append(course)
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let db = Firestore.firestore()
            db.collection("users").document(uid).collection("courses").document(courses[indexPath.row]["cid"] as! String).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "catsegue" {
            let nextViewController = segue.destination as? CategoryTableViewController
            let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let ref = "users/"+uid+"/courses/"+String(courses[selectedIndex!]["cid"]! as! String)+"/categories/"
            nextViewController?.navigationItem.title = courses[selectedIndex!]["cname"] as? String
            nextViewController?.ref = ref
        }
        if segue.identifier == "newcoursesegue" {
            let nc = segue.destination as! UINavigationController
            let nextViewController = nc.topViewController as? NewCourseTableViewController
            let ref = "users/"+uid+"/courses/"
            nextViewController?.ref = ref
        }
    }
    
}
