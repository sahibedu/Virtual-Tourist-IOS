//
//  AppDelegate.swift
//  Virtual-Tourist
//
//  Created by Sultan on 19/03/18.
//  Copyright © 2018 Sultan. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataController = DataController(modelName: "Virtual_Tourist")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let mapViewController = navigationController.topViewController as! MapViewViewController
        mapViewController.dataController = dataController
        
        return true
    }

}

