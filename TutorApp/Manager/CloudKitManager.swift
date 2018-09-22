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
    
    // MARK: - Creating A User
    
    static func createUserOfType(_ type: String, completion: @escaping (Bool) -> ()) {
        
        // Get user permission
        
        requestPermission { (granted) in
            if !granted { print("User did not provide permission");
              return }

            // We have user permission, so get the recordID
            
            getCurrentUserRecordID(completion: { (recordID) in
                guard let recordID = recordID else { fatalError("Could not get recordID") }
                let record = CKRecord(recordType: type)
                let recordName = recordID.recordName
                
                record["userRef"] = recordName as NSString
                
                // Save the record
                
                self.save([record]) { (success) in
                    completion(success)
                }
            })
        }
    }
    
    // MARK: - Requesting Permission
    
    static func requestPermission(completion: @escaping (Bool) -> ()) {
        container.requestApplicationPermission(.userDiscoverability) { (status, error) in
            if let error = error { print(#line, error.localizedDescription) }
            if status != .granted {
                completion(false)
            }
            completion(true)
        }
    }
    
    // MARK: - Saving Records
    
    private static func save(_ records: [CKRecord], completionHandler: ((Bool) -> ())?) {
        let op = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        op.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error { print(#line, error.localizedDescription); completionHandler?(false) }
            completionHandler?(true)
        }
        db.add(op)
    }
    
    // MARK: - Get Name
    
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
    
    // MARK: - Save Teacher Details
    
    static func saveTeacherDetailsWith(name: String, subject: String, image: UIImage?) {
        getCurrentUserRecordOfType("Teachers") { (teacher) in
            guard let teacher = teacher else { fatalError("No teacher")}
            teacher["subjectTeaching"] = subject as NSString
            teacher["name"] = name as NSString
            save([teacher], completionHandler: nil)
        }
    }
    
    // MARK: - Get 'Users' record
    
    private static func getUserWithID(_ id: CKRecordID, completion: @escaping (CKRecord?) -> ()) {
        db.fetch(withRecordID: id) { (user, error) in
            if let error = error { print(error.localizedDescription) }
            completion(user)
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


