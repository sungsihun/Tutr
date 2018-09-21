//
//  Teacher.swift
//  TutorApp
//
//  Created by NICE on 2018-09-20.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation
import UIKit

class Teacher {
  
    var name: String
    var subject: String
    var image: UIImage?
  
    init(name: String, subject: String, image: UIImage? = nil) {
        self.name = name
        self.subject = subject
        self.image = image
    }
}
