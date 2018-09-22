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
    
    
    //  Save Teacher Details
    
    static func saveTeacherDetailsWith(name: String, subject: String, image: UIImage, completion: @escaping (Bool, Teacher?) -> ()) {
        getCurrentUserRecordOfType("Teachers") { (teacher) in
            
            guard let teacher = teacher else { fatalError("No teacher")}
            teacher["subjectTeaching"] = subject as NSString
            teacher["name"] = name as NSString
            
            guard let data = UIImagePNGRepresentation(image) else { print("Could not turn image to data"); return}
            getDataURL(from: data, completion: { (url) in
                guard let url = url else { print("No url"); return }
                teacher["image"] = CKAsset(fileURL: url)
            })
            
            save([teacher]) { success in
                if success {
                    setRecordToUserDefaults(teacher)
                    let teacher = Teacher(teacher)
                    completion(true, teacher)
                }
                else { completion(false, nil) }
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
    
    
    
    // MARK: - HELPERS
    
    // MARK: - Get url of image
    
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
    
    // MARK: - Convert CKRecord To Data
    
    private static func setRecordToUserDefaults(_ record: CKRecord) {
        let data = NSKeyedArchiver.archivedData(withRootObject: record)
        UserDefaults.standard.set(data, forKey: "teacherRecord")
    }
    
    // MARK: - Get 'User' record from ID
    
    private static func getUserWithID(_ id: CKRecordID, completion: @escaping (CKRecord?) -> ()) {
        db.fetch(withRecordID: id) { (user, error) in
            if let error = error { print(error.localizedDescription) }
            completion(user)
        }
    }
    
    // MARK: - Get teacher
    
    static func getTeacher(completion: @escaping (Teacher?) -> ()) {
        getCurrentUserRecordOfType("Teachers") { (teacherRecord) in
            guard let teacherRecord = teacherRecord else { fatalError("No teacher!") }
            setRecordToUserDefaults(teacherRecord)
            let teacher = Teacher(teacherRecord)
            completion(teacher)
        }
    }
    
    // MARK - Get teacher or students record
    
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


