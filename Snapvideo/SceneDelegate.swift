//
//  SceneDelegate.swift
//  Snapvideo
//
//  Created by Anastasia Petrova on 02/02/2020.
//  Copyright © 2020 Anastasia Petrova. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
 
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
//    guard let path = Bundle.main.path(forResource: "videoTest", ofType:"MOV") else {
//        return
//    }
//    let url = URL(fileURLWithPath: path)
    let rootVC = HomeViewController()
    let navigationController = UINavigationController(rootViewController: rootVC)
//    window?.rootViewController = VideoViewController(url: url)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }
}

