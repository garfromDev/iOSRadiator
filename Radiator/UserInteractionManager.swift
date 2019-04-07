//
//  UserInteractionManager.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 01/01/2019.
//  Copyright © 2019 garfromDev. All rights reserved.
//

import Foundation
import UIKit

protocol UserInteractionCapable{
    var userInteractionManager: UserInteractionManager? {get}
}


protocol DistantFileManager{
    func push(data:Data, fileName:String)
    func pull(fileName:String, completion:@escaping DataCompletionHandler)
}

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

class UserInteractionManager{
    var userInteraction : UserInteraction = UserInteraction()
    var calendars : Calendars = Calendars()
    
    private var distantFileManager : DistantFileManager
    
    init(distantFileManager: DistantFileManager){
        self.distantFileManager = distantFileManager
        self.pullUpdate()
    }
    
    
    func pushUpdate(){
        self.distantFileManager.push(data:self.userInteraction.toJson(),
                                     fileName: Files.userInteraction)
        //self.distantFileManager.push(data: self.calendars.toJson(), fileName: Files.calendars)
    }
    
    
    func pullUpdate(){
        // call pullUpdate with a dummy handler, for local triggered update
        pullUpdate(handler:{(res:UIBackgroundFetchResult) in })
    }
    
    
    func pullUpdate(handler completionHandler: (UIBackgroundFetchResult) -> Void){
        // TODO: implémenter gestion du handler
        // get new value of UserInteraction
        self.distantFileManager.pull(fileName: Files.userInteraction){
            (result:DataOperationResult) in
            switch result{
            case .success(let data):
                if let newUsrInteraction = UserInteraction.fromJson(data: data){
                    self.userInteraction = newUsrInteraction
                }
            case .failure(let error):
                // in case of failure, we keep current data
                print("Failed to retrieve UserInteraction from server  ",  error.localizedDescription)
            }
        }
    }


}
