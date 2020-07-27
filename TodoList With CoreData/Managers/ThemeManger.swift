//
//  ThemeManger.swift
//  TodoList With CoreData
//
//  Created by sarath kumar on 25/07/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import Foundation
import UIKit

class ThemeManager {
    
    static func setup() {
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .gray
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            //Apply proxy
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = .gray
            UINavigationBar.appearance().isTranslucent = false
        }
    }
}
