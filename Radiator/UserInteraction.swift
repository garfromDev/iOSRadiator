//
//  UserInteraction.swift
//  Radiator
//
//  Created by Alistef on 30/12/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

// TODO: vérifier la jsonfification

import Foundation

enum HeatingMode:String , Codable{
    case confort = "confort"
    case eco = "eco"
    case unknow = "unknow"
}

struct OverruledStatus : Codable{
    var status : Bool = false
    var expirationDate : Date = Date(timeIntervalSince1970: 0)
    var overMode : HeatingMode = .unknow
}

struct DatedStatus : Codable {
    var status : Bool = false
    var expirationDate : Date = Date(timeIntervalSince1970: 0)
    
    static func makeTrue()->DatedStatus{
        var s = DatedStatus()
        s.status = true
        s.expirationDate = DatedStatus.defaultExpirationDate()
        return s
    }

    static func defaultExpirationDate()->Date{
        return Date(timeIntervalSinceNow: 24*60*60)
    }
}

struct UserInteraction : Codable{
    var overruled : OverruledStatus = OverruledStatus()
    var userBonus : DatedStatus = DatedStatus()
    var userDown : DatedStatus = DatedStatus()


}


extension UserInteraction {
    func toJson() ->Data {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        let dateFormat = DateFormatter.dateFormat(fromTemplate:"dd-MM-yyyy", options: 0, locale:Locale(identifier: "fr_FR"))
        formatter.dateFormat = dateFormat
        // la date obtenu sera du type 01/01/2000 à cause de la local fr, à voir si ça passe avec les codages utf8
        encoder.dateEncodingStrategy = .formatted(formatter)
        let data =  try! encoder.encode(self)
        return data
    }
    
    mutating func setDefaultExpirationDate(){
        self.overruled.expirationDate = Date(timeIntervalSinceNow: 24*60*60)
    }
    
 
}
