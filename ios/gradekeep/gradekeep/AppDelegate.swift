//
//  AppDelegate.swift
//  gradekeep
//
//  Created by Lee Angioletti on 4/25/18.
//  Copyright © 2018 Lee Angioletti. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        let db = Firestore.firestore()
        let uid = "aFor7zG6JZaFhtiNZrtcnUSCSNi1"
        
        // create courses array and insert course object
        var local_courses: [[String : Any]] = []
        let course: [String : Any] = [
            "cname" : "CS 348",
            "cweight" : 200
        ]
        let course2: [String : Any] = [
            "cname" : "CS 252",
            "cweight" : 100
        ]
        local_courses.append(course)

        // write into plist
        let path = Bundle.main.path(forResource: "local_courses", ofType: "plist")
        print(path)
        let url = URL(fileURLWithPath: path!)
        (local_courses as NSArray).write(to: url, atomically: true)

        updateLocalCourses(uid: uid, db: db)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getUID() -> String {
        return ""
    }
    
    func updateLocalCourses(uid: String, db: Firestore) {
        
        // build db_course array
        buildArr(ref: "users/" + uid + "/Courses", db: db)
    
        
    }
    
    func compPlist(resource1: String, resource2: String) -> Bool {
        let path1 = Bundle.main.path(forResource: resource1, ofType: "plist")
        let path2 = Bundle.main.path(forResource: resource2, ofType: "plist")
        return FileManager.default.contentsEqual(atPath: path1!, andPath: path2!)
    }
    
    func writeIntoPlist(arr: [[String : Any]], resource: String) {
        let path = Bundle.main.path(forResource: resource, ofType: "plist")
        let url = URL(fileURLWithPath: path!)
        (arr as NSArray).write(to: url, atomically: true)
    }
    
    func buildArr(ref: String, db: Firestore) {
        var arr: [[String : Any]] = []
        db.collection(ref).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    arr.append(document.data() as [String : Any])
                }
                // write into plist
                self.writeIntoPlist(arr: arr, resource: "db_courses")
                
                // compare local and db plist
                print(self.compPlist(resource1: "local_courses", resource2: "db_courses"))
            }
        }
    }
    
}

