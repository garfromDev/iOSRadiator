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
    
    func test10BackgroundFetch() {
        let got_response = XCTestExpectation(description: "10 got response")
        let positive_response = XCTestExpectation(description: "10 positive_answer")
        
            UIApplication.shared.delegate?.application?(UIApplication.shared, performFetchWithCompletionHandler: { result in
                got_response.fulfill()
                switch result{
                    case .newData:
                        positive_response.fulfill()
                    case .failed, .noData:
                        XCTFail("BackgroundFetch brings no data")
                    @unknown default:
                        XCTFail("BackgroundFetch brings no data")
                }
            }
            )
        wait(for: [got_response, positive_response], timeout: 20)
    }
    
    
    func test20Fromserver() {
        // get UserInteraction from server through UserInteractionManager
        let got_response = XCTestExpectation(description: "20_got response")
        let positive_response = XCTestExpectation(description: "20_positive_answer")
        
        UserInteractionManager.shared.pullUserInteraction() { result in
            got_response.fulfill()
            switch result{
                case .success(_):
                    positive_response.fulfill()
                case .failure(let error):
                    XCTFail("pullUserInteraction answered error \(error.localizedDescription)")
            }
        }
        wait(for: [got_response, positive_response], timeout: 20)
    }
    

    func test30PushToServer(){
        let positive_response = XCTestExpectation(description: "30_positive_answer")
        let errorHandler: (Error?)-> Void = {
            error in
            if error == nil { positive_response.fulfill() }
        }
        UserInteractionManager.shared = UserInteractionManager(distantFileManager: FTPfileUploader(errorHandler: errorHandler))
        UserInteractionManager.shared.pushUpdate()
        wait(for: [positive_response], timeout: 20)
    }


// MARK: Datasource
    func testDataSOurce() {
//        XCTAssert(caldrs.tableView(CalendarTableView(), numberOfRowsInSection: 0) == 2)
//        let cell = caldrs.tableView(CalendarTableView(), cellForRowAt: IndexPath(row: 0, section: 0))
//        XCTAssertNotNil(cell)
//        XCTAssert(cell.textLabel?.text == "vacances")
    }

}
