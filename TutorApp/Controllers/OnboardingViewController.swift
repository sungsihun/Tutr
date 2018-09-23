//
//  OnboardingViewController.swift
//  TutorApp
//
//  Created by Henry Cooper on 21/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    var userType: UserType?
    let userDefaults = UserDefaults.standard
    
    @IBAction func teacherButtonPressed(_ sender: Any) {
        userType = .Teachers
        performSegue(withIdentifier: "createUserSegue", sender: nil)
    }
    
    @IBAction func studentButtonPressed(_ sender: Any) {
        userType = .Students
        performSegue(withIdentifier: "createUserSegue", sender: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addUserNav = segue.destination as! UINavigationController
        let addUserVC = addUserNav.viewControllers.first! as! AddUserViewController
        addUserVC.userType = userType
        userDefaults.set(userType?.rawValue, forKey: "userType")

    }
    
    
    
    

}
