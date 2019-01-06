//
//  UserInteractionManager.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 01/01/2019.
//  Copyright © 2019 garfromDev. All rights reserved.
//

import Foundation

protocol DistantFileManager{
    func push(data:Data, fileName:String)
}


class UserInteractionManager{
    var userInteraction : UserInteraction = UserInteraction()
    private var distantFileManager : DistantFileManager
    
    init(distantFileManager: DistantFileManager){
        self.distantFileManager = distantFileManager
    }
    
    func update(){
        self.distantFileManager.push(data:self.userInteraction.toJson(), fileName: "userInteraction.json")
    }
}
