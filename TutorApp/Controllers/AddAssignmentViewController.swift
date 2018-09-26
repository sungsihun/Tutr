//
//  AddAssignmentViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-25.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

protocol AddAssignmentControllerDelegate: class {
  func removeBlurredBackgroundView()
}

class AddAssignmentViewController: UIViewController {

    weak var delegate: AddAssignmentControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
  
    override func viewDidLayoutSubviews() {
      view.backgroundColor = UIColor.clear

    }
  
    @IBAction func dismissTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
  
  @IBAction func addTapped(_ sender: UIButton) {
  }
  
}

