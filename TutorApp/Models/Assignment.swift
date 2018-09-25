//
//  Homework.swift
//  TutorApp
//
//  Created by Henry Cooper on 19/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation

class Assignment {
  
    var assignmentTitle: String
    var assignmentDescription: String
    
    init(assignmentTitle: String, assignmentDescription: String) {
        self.assignmentTitle = assignmentTitle
        self.assignmentDescription = assignmentDescription
    }
  
    init(assignmentTitle: String) {
      self.assignmentTitle = assignmentTitle
      self.assignmentDescription = ""
    }
}
