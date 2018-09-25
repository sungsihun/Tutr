//
//  OnboardingViewController.swift
//  TutorApp
//
//  Created by Henry Cooper on 21/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    let activeUser = ActiveUser.shared
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        activeUser.currentCategory = [.teacher, .student][sender.tag]
        performSegue(withIdentifier: "createUserSegue", sender: nil)
    }
    

}
