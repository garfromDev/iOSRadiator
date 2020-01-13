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
 There is one instance of UserInteractionManager (UIM) (singleton)
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let userInteractionManager = UserInteractionManager.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // launch BackgroundFetch mecanism
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        userInteractionManager.refresh()
        return true
    }

    /** response to background fetch
     pull update from UserInteractionManager, it will trigger UI update
     */
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("performFetchWithCompletionHandler")
        UserInteractionManager.shared.pull() { result in
            completionHandler(result)
            switch result{
                case .newData: // we trigger UI update because pull does not
                    self.userInteractionManager.UIupdate()
                default:
                    break
            }
        }
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
        userInteractionManager.refresh()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

// TODO: a supprimer?
extension UIApplication {
    /// will return currently showing view controller
    static var topMostUpdatableViewController: UI_Updatable? {
        return UIApplication.shared.keyWindow?.rootViewController?.updatableViewController
    }
}

