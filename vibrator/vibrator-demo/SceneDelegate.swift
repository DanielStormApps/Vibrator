//
//  SceneDelegate.swift
//
//  Created by Daniel Storm on 3/17/20.
//  Copyright © 2020 Daniel Storm (github.com/DanielStormApps).
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    // MARK: - UIWindowSceneDelegate
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
}
