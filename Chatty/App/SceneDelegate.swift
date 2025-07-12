//
//  SceneDelegate.swift
//  Chatty
//
//  Created by Emmanuel Pena on 7/7/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

                window = UIWindow(windowScene: windowScene)
                window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
                window?.makeKeyAndVisible()
            }
        }
    
