//
//  AppDelegate.swift
//  TutorApp
//
//  Created by Henry Cooper on 18/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        RunLoop.current.run(until: NSDate(timeIntervalSinceNow:1) as Date)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let current = ActiveUser.shared.currentCategory
        window?.rootViewController = storyboard.instantiateViewController(withIdentifier: current.rawValue)
        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let target = storyboard.instantiateViewController(withIdentifier: "Teachers")
        window?.rootViewController = target
        didLaunchFromShortcuts = true
    }
    
    


}

