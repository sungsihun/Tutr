//
//  Helpers.swift
//  TutorApp
//
//  Created by Henry Cooper on 25/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation
import UIKit

func setAlertWith(title: String, message: String, from view: UIViewController, handler: ((UIAlertAction) -> ())?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .default, handler: handler)
    alertController.addAction(okAction)
    view.present(alertController, animated: true, completion: nil)
}

