//
//  UIDevice+Extensions.swift
//
//  Created by Daniel Storm on 3/17/20.
//  Copyright © 2020 Daniel Storm (github.com/DanielStormApps).
//

import UIKit

extension UIDevice {
    
    static let isSimulator: Bool = {
    #if targetEnvironment(simulator)
        return true
    #else
        return false
    #endif
    }()
    
}
