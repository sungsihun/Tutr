//
//  InterfaceController.swift
//  Tutr Extension
//
//  Created by Henry Cooper on 03/10/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var table: WKInterfaceTable!
    var students = [String]()
    let sharedStudents = StudentNames.sharedInstance
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        students = sharedStudents.students
        loadStudents()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func loadStudents() {
        table.setNumberOfRows(students.count, withRowType: "NameRow")
        for i in 0..<students.count {
            if let row = table.rowController(at: i) as? NameRow {
                row.nameLabel.setText(students[i])
            }
        }
    }
    
}
