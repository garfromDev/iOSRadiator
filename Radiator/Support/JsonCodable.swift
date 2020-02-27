//
//  JsonCodable.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 27/02/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation

protocol jsonCodable: Codable{
    associatedtype T: Codable
    func toJson() -> Data
    /// factory method to create CalendarObject from json data
    static func fromJson(_ data: Data) -> T?
}

extension jsonCodable{
    func toJson() -> Data {
        let encoder = JSONEncoder()
        return  try! encoder.encode(self)
    }
    
    /// factory method to create CalendarObject from json data
    static func fromJson(_ data: Data) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from:data)
    }
}
