//
//  JsonCodable.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 27/02/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation

protocol jsonEncodable: Codable{
    associatedtype T: Codable
    func toJson() -> Data
}
extension jsonEncodable{
    func toJson() -> Data {
        let encoder = JSONEncoder()
        return  try! encoder.encode(self)
    }
}


protocol jsonDecodable: Codable {
    associatedtype T: Codable
    static func fromJson(_ data: Data) -> T?
}
extension jsonDecodable{
    /// factory method to create CalendarObject from json data
    static func fromJson(_ data: Data) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from:data)
    }
}

protocol jsonCodable : jsonEncodable, jsonDecodable{
}

