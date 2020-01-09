//
//  UserInteraction.swift
//  Radiator
//
//  Created by Alistef on 30/12/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//


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

    /**
     - return: the date of tomorrow (today + 24h.)
     Expiration is resetted at midnight, that is a date is expired
     as soon as the day 0 am is reached
     */
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
    // note : in case of jammed content, resulting mode
    // would be calendar without adjustement
    mutating func setOverruleMode(_ mode:HeatingMode){
        self.overruled.status = true
        self.setDefaultExpirationDate()
        self.overruled.overMode = mode
    }
    
    func confortMode()->Bool{
        return self.overruled.status &&
        isNotExpired(self.overruled.expirationDate) &&
        self.overruled.overMode == .confort
    }
    
    func ecoMode()->Bool{
        return self.overruled.status &&
            isNotExpired(self.overruled.expirationDate) &&
            self.overruled.overMode == .eco
    }
    
    
    func calendarMode()->Bool{
        return !self.confortMode() && !self.ecoMode()
    }
    
    
    func userBonusActive()->Bool{
        return self.userBonus.status &&
            !self.ecoMode() &&
            isNotExpired(self.userBonus.expirationDate)
    }
    
    func userDownActive()->Bool{
        return self.userDown.status &&
            !self.ecoMode() &&
            isNotExpired(self.userDown.expirationDate)
    }
    
    /** encode UserInteraction into json with date format compatible with python Radiator
    */
    func toJson() ->Data {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        let dateFormat = DateFormatter.dateFormat(fromTemplate:"dd-MM-yyyy", options: 0, locale:Locale(identifier: "fr_FR"))
        formatter.dateFormat = dateFormat
        // la date obtenu sera du type 01/01/2000 à cause de la local fr, ça passe avec les codages utf8
        encoder.dateEncodingStrategy = .formatted(formatter)
        let data =  try! encoder.encode(self)
        return data
    }
    
    
    /** check validity of expiration date
     date is expired as soon as 00:00 am of the day is reached
     */
    private func isNotExpired(_ expirationDate: Date)-> Bool{
        let c = Calendar(identifier: .gregorian)
        let expDay = c.component(.day, from: expirationDate)
        let day = c.component(.day, from: Date())
        return expDay > day
    }
    
    /** decode json file to UserInteraction object from python generated or swift generated json
     */
    static func fromJson(data:Data)->UserInteraction?{
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        let dateFormat = DateFormatter.dateFormat(fromTemplate:"dd-MM-yyyy", options: 0, locale:Locale(identifier: "fr_FR"))
        formatter.dateFormat = dateFormat
        // la date obtenu sera du type 01/01/2000 à cause de la local fr, ça passe avec les codages utf8
        decoder.dateDecodingStrategy = .formatted(formatter)
        return  try? decoder.decode(UserInteraction.self, from:data)
    }
    
    
    mutating func setDefaultExpirationDate(){
        self.overruled.expirationDate = Date(timeIntervalSinceNow: 24*60*60)
    }
    
 
}
