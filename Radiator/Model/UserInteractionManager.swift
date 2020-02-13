//
//  UserInteractionManager.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 01/01/2019.
//  Copyright © 2019 garfromDev. All rights reserved.
//

import Foundation
import os
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
    private let dfAccessSemaphore = DispatchSemaphore(value: 1) // first wait will bring gown to zero, blocking further wait
    private let sendRequestQueue = DispatchQueue(label:"sendRequestQueue", qos: .userInitiated)
    private let handleCallbackQueue = DispatchQueue(label:"handleCallbackQueue", qos: .userInitiated)
    private let distantFileManager : DistantFileManager
    private let log : OSLog!
    
    init(distantFileManager: DistantFileManager){
        self.distantFileManager = distantFileManager
        if #available(iOS 10.0, *) {
            log = OSLog.init(subsystem: "fr.garfromdev.radiator", category: "UserInteractionManager")
        }else{
            log = nil
        }
        super.init()
    }
    
    
    func pushUpdate(){
        self.distantFileManager.push(data:self.userInteraction.toJson(),
                                     fileName: Files.userInteraction)
        self.distantFileManager.push(data: self.calendars.toJson(),
                                     fileName: Files.calendars)
        self.UIupdate()
    }
    
    
    func pullCalendars(handler completionHandler: @escaping (Result<Calendars, IOError>  ) -> Void){
        sendRequestQueue.async {
            // first wait that any opened ftp Operation is finished
            _ = self.dfAccessSemaphore.wait(timeout: .now() + 20)
            self.handleCallbackQueue.async(){
                //treatment done on other serial queue, because sendRequestQueue may be bloqued by wait()
                self.distantFileManager.pull(fileName: Files.calendars){
                    (result:DataOperationResult) in
                    self.dfAccessSemaphore.signal() // release access for next operation
                    switch result{
                    case .success(let data):
                        if let newcalendars = Calendars.fromJson(data){
                            self.calendars = newcalendars
                            completionHandler(Result.success(newcalendars))
                            self.UIupdate()
                        }
                    case .failure(let error):
                        // in case of failure, we keep current data
                        completionHandler(Result.failure(.IOerror(msg: error.localizedDescription)))
                        if #available(iOS 10.0, *) {
                            os_log("Failed to retrieve Calendars from server %{public}@", log:self.log, type:.error, error.localizedDescription)
                        } else {
                            print("Failed to retrieve Calendars from server  \(error.localizedDescription)")
                        }
                    } //end switch
                } //end pull call back
            } // end handleCallBackQueue
        } //end requestQueue
    } // end pull function
    
    
    /// normal method to retrieve UserInteraction object, using handler
    func pullUserInteraction(handler completionHandler: @escaping (Result<UserInteraction, IOError>  ) -> Void){
        sendRequestQueue.async {
            // first wait that any opened ftp Operation is finished
            _ = self.dfAccessSemaphore.wait(timeout: .now() + 20)
            self.handleCallbackQueue.async(){
                //treatment done on other serial queue, because sendRequestQueue may be bloqued by wait()
                self.distantFileManager.pull(fileName: Files.userInteraction){
                    (result:DataOperationResult) in
                    self.dfAccessSemaphore.signal() // release access for next operation
                    switch result{
                    case .success(let data):
                        if let newUsrInteraction = UserInteraction.fromJson(data: data){
                            self.userInteraction = newUsrInteraction
                            completionHandler(Result.success(newUsrInteraction))
                            self.UIupdate()
                        }
                    case .failure(let error):
                        // in case of failure, we keep current data
                        completionHandler(Result.failure(.IOerror(msg: error.localizedDescription)))
                        if #available(iOS 10.0, *) {
                            os_log("Failed to retrieve Calendars from server %{public}@", log:self.log, type:.error, error.localizedDescription)
                        } else {
                            print("Failed to retrieve Calendars from server  \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    /** method to be called by BackgroundFetch mecanism.
     Will make  pull request and call completion handler after getting last result
     */
    func pull(handler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        self.pullCalendars() {
            result in return
        }
        self.pullUserInteraction() {
            result in
            switch result {
            case .success(_):
                completionHandler(.newData)
            case .failure:
                completionHandler(.failed)
            }
        }
    }
    
    /**
     will pull new data and called UI refreshing asynchonously
     */
    func refresh(){
        self.pullUserInteraction() { _ in return }
        self.pullCalendars() { _ in self.UIupdate() } // because of serial mechanism, will be executed last
    }
    
    
    func UIupdate() {
        NotificationCenter.default.post(Notification(name:UserInteractionManager.updateUInotification, object: self))
    }
    
} // end of class UserInteractionManager
