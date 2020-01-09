//
//  RadiatorTests.swift
//  RadiatorTests
//
//  Created by Alistef on 20/12/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

import XCTest
@testable import Radiator

class CalendarsTests: XCTestCase {
    let caldrs : Calendars = Calendars()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        caldrs.list["travail"] = "regular.json"
        caldrs.list["vacances"] = "holidays.json"
    }

    
    //MARK: CalendarObject & Calendars
    func testToAndFromJson() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertNotNil(caldrs)
        let json = caldrs.toJson()
        XCTAssertNotNil(json)
        let newCals = Calendars.fromJson(json)!
        XCTAssertNotNil(newCals)
        XCTAssert(newCals.list.count == 2)
        XCTAssert(newCals.list["vacances"] == "holidays.json")
    }
    
    func testNames() {
        XCTAssert(caldrs.names.count == 2)
        XCTAssert(caldrs.names.contains("vacances"))
    }

    func testFromJsonFile() throws {
        let appBundle = Bundle(for: type(of: self))
        guard let file = appBundle.url(forResource: "testCalendars", withExtension: "json") else {
            XCTFail("testCalendars not found")
            return
        }
        let data = try Data(contentsOf: file)
        guard let myCals = Calendars.fromJson(data) else {
            XCTFail("unable to decode json")
            return
        }
        XCTAssert(myCals.currentCalendar == "vacances")
        XCTAssert(myCals.list.count == 2)
    }
    
    
// MARK: Datasource
    func testDataSOurce() {
        XCTAssert(caldrs.tableView(CalendarTableView(), numberOfRowsInSection: 0) == 2)
        let cell = caldrs.tableView(CalendarTableView(), cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNotNil(cell)
        XCTAssert(cell.textLabel?.text == "vacances")
    }

}
