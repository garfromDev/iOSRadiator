//
//  RadiatorTests.swift
//  RadiatorTests
//
//  Created by Alistef on 20/12/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

import XCTest
@testable import Radiator

// A test method is an instance method of a test class that begins with the prefix test, takes no parameters, and returns void,

class CalendarsTests: XCTestCase {
    let caldrs : Calendars = Calendars()
    let positive_response = XCTestExpectation(description: "30_positive_answer")
    
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
    
    func testCalendarsDataSource() throws {
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
        let tbv = UITableView()
        tbv.register(UITableViewCell.self, forCellReuseIdentifier: cellsID.calendarTableViewCell.rawValue)
        var cell = myCals.tableView(tbv, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(cell.textLabel?.text == Array(myCals.list.keys)[0])
        cell = myCals.tableView(tbv, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(cell.textLabel?.text == Array(myCals.list.keys)[1])
        XCTAssert(myCals.tableView(tbv, numberOfRowsInSection: 0) == 2)
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
    
    
    func receivedUpdateUi(_ : Notification){
        positive_response.fulfill()
    }
    

    func test30PushToServer(){
        _ = NotificationCenter.default.addObserver(self, selector: #selector(receivedUpdateUi(_:))
            , name: UserInteractionManager.updateUInotification,
              object : nil)
        UserInteractionManager.shared = UserInteractionManager(distantFileManager: FTPfileUploader())
        UserInteractionManager.shared.pushUpdate()
        wait(for: [positive_response], timeout: 20)
    }

    
    func test40CalendarFromserver() {
        // get UserInteraction from server through UserInteractionManager
        let got_response = XCTestExpectation(description: "40_got response")
        let positive_response = XCTestExpectation(description: "40_positive_answer")
        
        UserInteractionManager.shared.pullCalendars() { result in
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
    
    
    func test50TripleCallFromserver() {
        // make 3 request without waiting, serial mechanism of userInteraction should protect against too many connexions
        let positive_response1 = XCTestExpectation(description: "50_positive_answer1")
        let positive_response2 = XCTestExpectation(description: "50_positive_answer1")
        let positive_response3 = XCTestExpectation(description: "50_positive_answer1")
         UserInteractionManager.shared.pullCalendars() { result in
             switch result{
                 case .success(_):
                     positive_response1.fulfill()
                 case .failure(let error):
                     XCTFail("pullUserInteraction 1 answered error \(error.localizedDescription)")
             }
         }
        UserInteractionManager.shared.pullCalendars() { result in
            switch result{
                case .success(_):
                    positive_response2.fulfill()
                case .failure(let error):
                    XCTFail("pullUserInteraction 2 answered error \(error.localizedDescription)")
            }
        }
        UserInteractionManager.shared.pullCalendars() { result in
            switch result{
                case .success(_):
                    positive_response3.fulfill()
                case .failure(let error):
                    XCTFail("pullUserInteraction 3 answered error \(error.localizedDescription)")
            }
        }
         wait(for: [positive_response1, positive_response2, positive_response3], timeout: 40)
    }

} //end CalendarsTest
