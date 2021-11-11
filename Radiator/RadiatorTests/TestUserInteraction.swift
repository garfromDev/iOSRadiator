//
//  TestUserInteraction.swift
//  RadiatorTests
//
//  Created by Alistef on 11/11/2021.
//  Copyright © 2021 garfromDev. All rights reserved.
//

import XCTest
@testable import Radiator

class TestUserInteraction: XCTestCase {

    var formater = DateFormatter()
    
    override func setUp() {
        formater.dateFormat = "dd/MM/yyyy"
    }
    
    /** test decoding of UserInteraction object from json file */
    func testFromJsonFile() throws {
        let appBundle = Bundle(for: type(of: self))
        guard let file = appBundle.url(forResource: "userInteraction", withExtension: "json") else {
            XCTFail("userInteraction.json not found")
            return
        }
        let data = try Data(contentsOf: file)
        guard let myUsri = UserInteraction.fromJson(data: data) else {
            XCTFail("unable to decode json")
            return
        }
        XCTAssert(myUsri.overruled.status == true)
        XCTAssert(myUsri.overruled.overMode == .eco)
        XCTAssert(myUsri.userBonus.status == true)
        XCTAssert(myUsri.userDown.status == false)
        print(myUsri.overruled.expirationDate)
        XCTAssert(myUsri.overruled.expirationDate >= formater.date(from: "11/11/2021")!)
        XCTAssert(myUsri.userBonus.expirationDate <= formater.date(from: "02/01/1970")!)
        XCTAssert(myUsri.userDown.expirationDate <= formater.date(from: "02/01/1970")!)
    }

}
