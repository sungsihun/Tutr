//
//  Student.swift
//  TutorApp
//
//  Created by Henry Cooper on 18/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation
import UIKit

class Student {
    
    var id: UUID
    var name: String
    var age: Int
    var subjectStudying: String
    var image: UIImage?
    var assignments = [Assignment]()
    
    init(name: String, age: Int, subjectStudying: String, image: UIImage? = nil) {
        let uuid = UUID()
        self.id = uuid
        self.name = name
        self.age = age
        self.subjectStudying = subjectStudying
        self.image = image
    }
    
}
