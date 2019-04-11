//
//  UserInteractionManager.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 01/01/2019.
//  Copyright © 2019 garfromDev. All rights reserved.
//

import Foundation
import UIKit

/// utility of this protocol not clear
protocol UserInteractionCapable{
    var userInteractionManager: UserInteractionManager? {get}
}

/** describe an object capable of pushing / retrieving file from distant system */
protocol DistantFileManager{
    func push(data:Data, fileName:String)
    func pull(fileName:String, completion:@escaping DataCompletionHandler)
}

/** constant for files used in Radiator */
struct Files{
    static let userInteraction = "userInteraction.json"
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
    
    private var distantFileManager : DistantFileManager
    var observer : UI_Updatable?
    
    init(distantFileManager: DistantFileManager, observer:UI_Updatable? = nil){
        self.distantFileManager = distantFileManager
        self.observer = observer
        super.init()
        self.pullUpdate()
    }
    
    
    func pushUpdate(){
        self.distantFileManager.push(data:self.userInteraction.toJson(),
                                     fileName: Files.userInteraction)
        //self.distantFileManager.push(data: self.calendars.toJson(), fileName: Files.calendars)
        self.UIupdate()
    }
    
    
    func pullUpdate(){
        // call pullUpdate with a dummy handler, for local triggered update
        pullUpdate(handler:{(res:UIBackgroundFetchResult) in })
    }
    
    
    func pullUpdate(handler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        print("UserInteractionManager pulling update")
        // get new value of UserInteraction
        self.distantFileManager.pull(fileName: Files.userInteraction){
            (result:DataOperationResult) in
            switch result{
            case .success(let data):
                print("Distant file manager has got datas")
                completionHandler(.newData)
                if let newUsrInteraction = UserInteraction.fromJson(data: data){
                    self.userInteraction = newUsrInteraction
                    print("UserInteractionManager.userinteraction has new value \(newUsrInteraction)")
                    self.UIupdate()
                }
            case .failure(let error):
                // in case of failure, we keep current data
                completionHandler(.failed)
                print("Failed to retrieve UserInteraction from server  ",  error.localizedDescription)
            }
        }
    }

    
    private func UIupdate() {
        DispatchQueue.main.async { [weak self] in
            self?.observer?.updateUI(timestamp: "dernière mise  à jour le \(Date().description(with: .current))")
        }
    }
    
} // end of class UserInteractionManager
