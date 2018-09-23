//
//  CloudKitManager.swift
//  TutorApp
//
//  Created by Henry Cooper on 21/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


class CloudKitManager {
    
    
    static let container = CKContainer(identifier: "iCloud.com.henry.CloudKitScratch")
    static let db = container.publicCloudDatabase
    
    // MARK: - USERS
    
    // Creating A User
    
    static func createUserOfType(_ type: String, completion: @escaping (Bool) -> ()) {
        
        // Get user permission
        
        requestPermission { (granted) in
            if !granted { print("User did not provide permission");
                return }
            
            // We have user permission, so get the recordID
            
            getCurrentUserRecordID { (recordID) in
                guard let recordID = recordID else { fatalError("Could not get recordID") }
                let record = CKRecord(recordType: type)
                let recordName = recordID.recordName
                
                record["userRef"] = recordName as NSString
                
                // Save the record
                
                self.save([record]) { (success) in
                    completion(success)
                }
            }
        }
    }
    
    //  Requesting Permission
    
    static func requestPermission(completion: @escaping (Bool) -> ()) {
        container.requestApplicationPermission(.userDiscoverability) { (status, error) in
            if let error = error { print(#line, error.localizedDescription) }
            if status != .granted {
                completion(false)
            }
            completion(true)
        }
    }
    
    //  Saving Records
    
    private static func save(_ records: [CKRecord], completionHandler: ((Bool) -> ())?) {
        let op = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        op.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error { print(#line, error.localizedDescription); completionHandler?(false) }
            completionHandler?(true)
        }
        db.add(op)
    }
    
    //  Get Name Of User
    
    static func getCurrentUserName(completion: @escaping (String?, String?) -> ()) {
        getCurrentUserRecordID { (recordID) in
            guard let recordID = recordID else { fatalError("Could Not get recordID") }
            container.discoverUserIdentity(withUserRecordID: recordID, completionHandler: { (userId, error) in
                if let error = error { print(error.localizedDescription); return }
                guard let userId = userId else { return }
                completion(userId.nameComponents?.givenName, userId.nameComponents?.familyName)
            })
        }
    }
    
    static func getCurrentUserRecordID(completion: @escaping (CKRecordID?) -> ()) {
        container.fetchUserRecordID { (recordID, error) in
            if let error = error { print(error.localizedDescription); return }
            completion(recordID)
        }
    }
    
    
    
    
    
    
    
    // MARK: - TEACHERS
    
    
    //  Save User Details
    
    static func saveUserDetails(type: UserType, name: String, subject: String, image: UIImage, completion: @escaping (Bool, Teacher?, Student?) -> ()) {
        getCurrentUserRecordOfType(type.rawValue) { (user) in
            
            guard let user = user else { fatalError("No user") }
            
            user["name"] = name as NSString
            guard let data = UIImagePNGRepresentation(image) else { print("Could not turn image to data"); return}
            getDataURL(from: data){ (url) in
                guard let url = url else { print("No url"); return }
                user["image"] = CKAsset(fileURL: url)
            }
            
            switch type {
            case .Teachers: user["subjectTeaching"] = subject as NSString
            case .Students: user["subjectStudying"] = subject as NSString
            }
            
            save([user]) { success in
                if success {
                    setRecordToUserDefaults(user)
                    
                    switch type {
                    case .Teachers: let teacher = Teacher(user); completion(true, teacher, nil)
                    case .Students: let student = Student(user); completion(true, nil, student)
                    }
                    
                }
                else { completion(false, nil, nil) }
            }
        }
    }
    
    
    
    // MARK: - STUDENTS
    
    // Fetch students
    
    static func fetchAllStudentsFrom(_ teacher: Teacher, completion: @escaping ([Student]?) -> ()) {
        
        guard let record = teacher.record else { fatalError("Teacher has no record") }
        
        // Get the array of the teacher's students
        
        guard let studentRefs = record["students"] as? Array<CKReference>  else { completion(nil); return }
        
        // Get the recordID of each student
        
        let ids = studentRefs.map{ $0.recordID }
        
        // Get the record of each student
        
        let op = CKFetchRecordsOperation(recordIDs: ids)
        var returnStudents = [Student]()
        
        // Below is essentially a loop that is called for each record got
        op.fetchRecordsCompletionBlock = { dict, error in
            if let dict = dict {
                for (_, record) in dict {
                    guard let student = Student(record) else { continue }
                    returnStudents.append(student)
                }
                completion(returnStudents)
            }
            completion(nil)
        }
        
        // results is now an array of CKRecords with the students of the teacher
        db.add(op)
    }
    
    static private func getRecordFromID(_ id: CKRecordID, completion: @escaping (CKRecord?) -> ()) {
        let predicate = NSPredicate(format: "userRef = %@", id.recordName)
        let query = CKQuery(recordType: "Students", predicate: predicate)
        
        db.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error { print(error.localizedDescription); completion(nil) }
            completion(records?.first)
        }
    }
    
    static func getStudentFromID(_ id: CKRecordID, completion: @escaping (Student?) -> ()) {
        getRecordFromID(id) { (record) in
            guard let record = record else { completion(nil); return }
            let student = Student(record)
            completion(student)
        }
    }
    
    
    // Search for student
    
    static func findStudentWith(email: String, completion: @escaping (Student?) -> ()) {
        container.discoverUserIdentity(withEmailAddress: email) { (userIdentity, error) in
            if let error = error { print(error.localizedDescription); completion(nil) }
            guard let userIdentity = userIdentity,
                let recordID = userIdentity.userRecordID
                else { completion(nil); return }
            print(recordID.recordName)
            getStudentFromID(recordID) { (student) in
                completion(student)
            }
        }
    }
        
        
        
        // MARK: - HELPERS
        
        //  Get url of image
        
        private static func getDataURL(from data: Data, completion: (URL?) -> ()) {
            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID()).dat")
            do {
                try data.write(to: url)
                completion(url)
            } catch {
                completion(nil)
                print(error.localizedDescription)
            }
        }
        
        //  Convert CKRecord To Data
        
        private static func setRecordToUserDefaults(_ record: CKRecord) {
            let data = NSKeyedArchiver.archivedData(withRootObject: record)
            UserDefaults.standard.set(data, forKey: "userRecord")
        }
        
        // Get 'User' record from ID
        
        private static func getUserWithID(_ id: CKRecordID, completion: @escaping (CKRecord?) -> ()) {
            db.fetch(withRecordID: id) { (user, error) in
                if let error = error { print(error.localizedDescription) }
                completion(user)
            }
        }
        
        //  Get teacher
        
        static func getTeacher(completion: @escaping (Teacher?) -> ()) {
            getCurrentUserRecordOfType("Teachers") { (teacherRecord) in
                guard let teacherRecord = teacherRecord else { fatalError("No teacher!") }
                setRecordToUserDefaults(teacherRecord)
                let teacher = Teacher(teacherRecord)
                completion(teacher)
            }
        }
        
        // Get teacher or students record
        
        private static func getCurrentUserRecordOfType(_ type: String, completion: @escaping (CKRecord?) -> ()) {
            
            getCurrentUserRecordID { (recordID) in
                guard let recordID = recordID else { fatalError("Could not get recordID") }
                
                // Wrapper around the recordID
                
                let predicate = NSPredicate(format: "userRef = %@", recordID.recordName)
                let query = CKQuery(recordType: type, predicate: predicate)
                
                self.db.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                    if let error = error { print(#line, error.localizedDescription); return }
                    guard let record = records?.first else {
                        print("No record exists")
                        completion(nil)
                        return
                    }
                    completion(record)
                })
            }
        }
}


