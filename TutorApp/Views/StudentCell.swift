//
//  StudentCell.swift
//  TutorApp
//
//  Created by Henry Cooper on 18/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentImageView: StudentImageView!
    
    
    // MARK: - Custom Methods

    func configure(with student: Student) {
        studentNameLabel.text = student.name
        
        if let studentImage = student.image {
            studentImageView.image = studentImage
        }
    }
    
}


