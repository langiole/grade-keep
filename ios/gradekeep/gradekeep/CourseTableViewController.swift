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

    var courses: [Course] = []
    let uid = "aFor7zG6JZaFhtiNZrtcnUSCSNi1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up courses listener
        let db = Firestore.firestore()
        db.collection("users/aFor7zG6JZaFhtiNZrtcnUSCSNi1/courses").order(by: "course_name")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                self.courses.removeAll()
                for document in documents {
                    var course = Course()
                    course.course_id = document.documentID
                    course.course_name = document.data()["course_name"] as! String
                    course.course_grade = document.data()["course_grade"] as! Double
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
        courseNameLabel.text = courses[indexPath.row].course_name as? String
        
        let courseGradeLabel = cell.viewWithTag(2) as! UILabel
        let x = courses[indexPath.row].course_grade as? Double
        courseGradeLabel.text = "\(x!)" + "%"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let db = Firestore.firestore()
            db.collection("users").document(uid).collection("courses").document(courses[indexPath.row].course_id as! String).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        // init alert menu
        let menu = UIAlertController(title: nil, message: "Create new", preferredStyle: .actionSheet)
        
        // set up menu actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        let newCourseAction = UIAlertAction(title: "Course", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "editcoursesegue", sender: nil)
        })
        let newCatAction = UIAlertAction(title: "Category", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        let newAssAction = UIAlertAction(title: "Assignment", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        // add actions to menu
        menu.addAction(cancelAction)
        menu.addAction(newCourseAction)
        menu.addAction(newCatAction)
        menu.addAction(newAssAction)
        
        self.present(menu, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "catsegue" {
            let nextViewController = segue.destination as? CategoryTableViewController
            let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let ref = "users/"+uid+"/courses/"+String(courses[selectedIndex!].course_id as! String)+"/categories/"
            nextViewController?.navigationItem.title = courses[selectedIndex!].course_name as? String
            nextViewController?.ref = ref
        }
        if segue.identifier == "newcoursesegue" {
            let nextView = segue.destination as! UINavigationController
            let courseView = nextView.topViewController as? NewCourseTableViewController
            let ref = "users/"+uid+"/courses/"
            courseView?.ref = ref
        }
    }
    
}
