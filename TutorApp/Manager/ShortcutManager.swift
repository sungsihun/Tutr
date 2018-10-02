//
//  ShortcutManager.swift
//  TutorApp
//
//  Created by Henry Cooper on 02/10/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation
import UIKit

struct ShortcutManager {
    
    static func setShortcutItem() -> [UIApplicationShortcutItem] {
        let item = UIApplicationShortcutItem(type: "Add Student", localizedTitle: "Add Student", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
        return [item]
    }
}
