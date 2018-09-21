//
//  TeacherCell.swift
//  TutorApp
//
//  Created by NICE on 2018-09-20.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class TeacherCell: UITableViewCell {

    // MARK: - Outlets
  
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var teacherImageView: TeacherImageView!
  
    // MARK: - Custom Methods
    
    func configure(with teacher: Teacher) {
      nameLabel.text = teacher.name
      subjectLabel.text = teacher.subject
      
      if let teacherImage = teacher.image {
          teacherImageView.image = teacherImage
      }
    }
}
