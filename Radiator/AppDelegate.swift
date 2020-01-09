//
//  AppDelegate.swift
//  Radiator
//
//  Created by Alistef on 20/12/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

import UIKit

/*
 APP STRUCTURE
 the source of truth are the distant files (today in FTP repo)
 There is one instance of UserInteractionManager (UIM) (global var)
 All controllers get the model from the UIM
 All controllers locally update model in response to user action and push to UIM
 UIM pull from distant repo (Backgroundfetch or other mechanism) and triggers
 UIUpdate notification.
 controller refresh model from UIM and update their UI upon this notification
 
 Principles :
 controllers are as light as possible
 they are specific to the app
 they know the model, all interactions through UIM
 it means we can change the distant file structure (REST instead of FTP, od even SQL) without impact
 UIM do not need to know how many controller, which can of UI ...
 */

// global singleton to handle all interaction with other Apps and Radiator devices
let userInteractionManager = UserInteractionManager(distantFileManager: FTPfileUploader())


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        let u = UserInteraction()
//        print(String(data: u.toJson(), encoding: .utf8)!)
        
        // launch BackgroundFetch mecanism
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        UIApplication.topMostUpdatableViewController?.updateUI(timestamp: "déclenché par launch le \(Date().description(with: .current))")
        return true
    }

    /** response to background fetch
     pull update from UserInteractionManager, it will trigger UI update
     */
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("performFetchWithCompletionHandler")
        guard let mainController = window?.rootViewController as? UserInteractionCapable else {
            completionHandler(.failed)
            print("fetch cancelled because no ViewControlelr")
            return
        }
        mainController.userInteractionManager?.pullUpdate(handler: completionHandler)
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        guard let controller = UIApplication.topMostUpdatableViewController else {return}
        controller.updateUI(timestamp: "déclenché par didBecomeAxctive le \(Date().description(with: .current))")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


extension UIApplication {
    /// will return currently showing view controller
    static var topMostUpdatableViewController: UI_Updatable? {
        return UIApplication.shared.keyWindow?.rootViewController?.updatableViewController
    }
}

