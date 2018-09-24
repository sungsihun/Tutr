//
//  StudentCell.swift
//  TutorApp
//
//  Created by Henry Cooper on 18/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentImageView: StudentImageView!
    
    
    // MARK: - Custom Methods

    func configure(with student: Student) {
        studentNameLabel.text = student.name
        subjectLabel.text = student.subject
        
        if let studentImage = student.image {
            studentImageView.image = studentImage
        }
    }
    
}


