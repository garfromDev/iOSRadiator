//
//  UserInteractionManager.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 01/01/2019.
//  Copyright © 2019 garfromDev. All rights reserved.
//

import Foundation
import UIKit

/** describe an object capable of pushing / retrieving file from distant system */
protocol DistantFileManager{
    func push(data:Data, fileName:String)
    func pull(fileName:String, completion:@escaping DataCompletionHandler)
    func pullSync(fileName:String)->DataOperationResult
}

/** constant for files used in Radiator */
struct Files{
    static let userInteraction = "userinteraction.json"
    static let calendars = "calendars.json"
    static let currentStatus = "currentStatus.json"
}

/*
Principe de fonctionnement de l'application
a l'apparition de la vue, charger la liste des calendrier, le calendrier courant, le userStatus courant, les infos courantes
Si modification par l'utilisateur, on push le modèle
On check régulièrement si apparition de changement (via le système de fetch)
 Les infos sont contenus dans :
 un fichier UserInteraction.json pour les overrules
 un fichiers calendars.json, contenant les différents CalendarObject et le nom du calendar actif
 un fichier currentStatus.json contenant les infos remonté par la raspberry (lecture uniquement)
*/



/**
 controller must add itself to observer to get UI_Update() notification
 controller fetch and set  userInteraction data using UserInteraction method
 controller triggers push to distant file, this will trigger UI update as well
 pull is also triggered by Backgroundfetch mecanism, defined in AppDelegate
*/
class UserInteractionManager:NSObject{
    var userInteraction : UserInteraction = UserInteraction()
    var calendars : Calendars = Calendars()
    // singleton
    static var shared = UserInteractionManager(distantFileManager: FTPfileUploader())
    static let updateUInotification = Notification.Name("updateUI")
    enum IOError: Error {
        case IOerror(msg: String)
    }
    private let semaphore = DispatchSemaphore(value: 0)
    private let distantFileManager : DistantFileManager

    init(distantFileManager: DistantFileManager){
        self.distantFileManager = distantFileManager
        super.init()
        // self.refresh()
    }

    
    func pushUpdate(){
        self.distantFileManager.push(data:self.userInteraction.toJson(),
                                     fileName: Files.userInteraction)
        self.distantFileManager.push(data: self.calendars.toJson(),
                                     fileName: Files.calendars)
        self.UIupdate()
    }
    
    
    func pullCalendars(handler completionHandler: @escaping (Result<Calendars, IOError>  ) -> Void){
        fatalError()
        print("userIntercationManager async pulling calendars")
        self.distantFileManager.pull(fileName: Files.calendars){
            (result:DataOperationResult) in
            switch result{
                case .success(let data):
                    print("Distant file manager has got calendars datas")
                    if let newcalendars = Calendars.fromJson(data){
                        self.calendars = newcalendars
                        completionHandler(Result.success(newcalendars))
                        print("UserInteractionManager.calendars has new value \(newcalendars)")
                        self.UIupdate()
                }
                case .failure(let error):
                    // in case of failure, we keep current data
                    completionHandler(Result.failure(.IOerror(msg: error.localizedDescription)))
                    print("Failed to retrieve Calendars from server  ",  error.localizedDescription)
            }
            
        }
    }
    

    /// normal method to retrieve UserInteraction object, using handler
    func pullUserInteraction(handler completionHandler: @escaping (Result<UserInteraction, IOError>  ) -> Void){
        print("UserInteractionManager pulling async Userinteraction")
        self.distantFileManager.pull(fileName: Files.userInteraction){
            (result:DataOperationResult) in
            switch result{
                case .success(let data):
                    print("Distant file manager has got datas for user interaction")
                    if let newUsrInteraction = UserInteraction.fromJson(data: data){
                        self.userInteraction = newUsrInteraction
                        completionHandler(Result.success(newUsrInteraction))
                        print("UserInteractionManager.userinteraction has new value \(newUsrInteraction)")
                        self.UIupdate()
                }
                case .failure(let error):
                    // in case of failure, we keep current data
                    completionHandler(Result.failure(.IOerror(msg: error.localizedDescription)))
                    print("Failed to retrieve UserInteraction from server  ",  error.localizedDescription)
            }
            
        }
    }
    
    /** method to be called by BackgroundFetch mecanism.
     Will make synchro pull request and call completion handler
     */
    func pull(handler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        print("UserInteractionManager pulling update sync")
        var failed = false
        // get new value of UserInteraction
        var result = self.distantFileManager.pullSync(fileName: Files.userInteraction)
        print("result from pullsync userInteraction")
        switch result {
            case .success(let usrInteraction):
                self.userInteraction = UserInteraction.fromJson(data: usrInteraction) ?? self.userInteraction
            case .failure:
                failed = true
        }
        result = self.distantFileManager.pullSync(fileName: Files.calendars)
        print("result from pullsync calendars")
        switch result {
            case .success(let cldrs):
                self.calendars = Calendars.fromJson(cldrs) ?? self.calendars
            case .failure:
                if failed { // we consider failed if both pull have failed
                    completionHandler(.failed)
                    return
            }
        }
        completionHandler(.newData)
    }

    /**
        will pull new data and called UI refreshing asynchonously
     */
    func refresh(){
        fatalError()
        self.pullUserInteraction() { _ in self.UIupdate() }
        self.pullCalendars() { _ in self.UIupdate() }
    }
    
    
    func UIupdate() {
        NotificationCenter.default.post(Notification(name:UserInteractionManager.updateUInotification, object: self))
    }
    
} // end of class UserInteractionManager
