//
//  CustomTabBarController.swift
//  myMessenger
//
//  Created by Jesus Adolfo on 17/04/16.
//  Copyright © 2016 Jesus Adolfo. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        let friendsController = FriendsController(collectionViewLayout: layout)
        let recentMessagesNavController = UINavigationController(rootViewController: friendsController)
        recentMessagesNavController.tabBarItem.title = "Recent"
        recentMessagesNavController.tabBarItem.image = UIImage(named: "recents")

        
        
        viewControllers = [recentMessagesNavController,
                           createDummyNavControllerWithTitle("Calls", imageName: "phone"),
                           createDummyNavControllerWithTitle("Groups", imageName: "groups"),
                           createDummyNavControllerWithTitle("People", imageName: "list"),
                           createDummyNavControllerWithTitle("Settings", imageName: "settings"),
        
        ]
    }
    
    fileprivate func createDummyNavControllerWithTitle(_ title: String, imageName: String) -> UINavigationController {
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
}
