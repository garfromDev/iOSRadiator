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
    case confort = "CONFORT"
    case eco = "ECO"
    case unknow = "UNKNOW"
}

struct OverruledStatus : Codable{
    var status : Bool = false
    var expirationDate : Date = Date(timeIntervalSince1970: 0)
    var overMode : HeatingMode = .unknow
}

struct DatedStatus : Codable {
    var status : Bool = false
    var expirationDate : Date = Date(timeIntervalSince1970: 0)
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
}
