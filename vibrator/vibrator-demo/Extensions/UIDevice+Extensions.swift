//
//  UIDevice+Extensions.swift
//
//  Created by Daniel Storm on 3/17/20.
//  Copyright © 2020 Daniel Storm (github.com/DanielStormApps).
//

import UIKit

extension UIDevice {
    
    static let isSimulator = UIDevice.current.modelName == Model.simulator.rawValue
    
    private var modelName: String {
        return name(for: modelIdentifier())
    }
    
    private func modelIdentifier() -> String {
        var systemInfo: utsname = utsname()
        uname(&systemInfo)
        
        let machineMirror: Mirror = Mirror(reflecting: systemInfo.machine)
        let identifier: String = machineMirror.children.reduce(String()) { identifier, element in
            guard
                let value: Int8 = element.value as? Int8,
                value != 0
                else { return identifier }
            
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    private func name(for modelIdentifier: String) -> String {
        switch modelIdentifier {
        case "x86_64": return Model.simulator.rawValue
        default: return modelIdentifier
        }
    }
    
    private enum Model: String {
        case simulator = "Simulator"
    }
    
}
