//
//  testDayTemplate.swift
//  RadiatorTests
//
//  Created by Alistef on 11/11/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation
import XCTest
@testable import Radiator

class TestDayTemplate : XCTestCase {
 
    func testQuarterComparable(){
        let q1545 = QuarterTemplate(heatMode: .eco, hour: "15:45")
        let q1715 = QuarterTemplate(heatMode: .confort, hour: "17:15")
        XCTAssertLessThan(q1545, q1715, "QuarterTemplate ordered by hour")
        XCTAssertEqual(q1545, QuarterTemplate(heatMode: .eco, hour: "15:45"))
        XCTAssertNotEqual(q1545, QuarterTemplate(heatMode: .confort, hour: "15:45"))
    }
}


class TestDAylyEditing : XCTestCase {
    func testDaysExclusive(){
        let de = DaylyEditing()
        var weekIndicator = DayIndicators.forDays([Days.Monday, Days.Tuesday, Days.Wenesday, Days.Thursday, Days.Friday])
        var weekendIndicator = DayIndicators.forDays([Days.Saturday, Days.Sunday])
        let week = DayGroupEditing(applicableTo: weekIndicator, dayTemplate: DayTemplate())
        let weekend = DayGroupEditing(applicableTo: weekendIndicator, dayTemplate: DayTemplate())
        de.templates = [week, weekend]
        
        XCTAssertTrue(de.templates.first!.applicableTo.contains(DayIndicator(day: .Wenesday, active: true)), "Wenesday is in week")
        XCTAssertFalse(de.templates.last!.applicableTo.contains(DayIndicator(day: .Wenesday, active: true)), "Wenesday is not in weekend")
        
        weekend.addDay(day: .Wenesday)
        
        XCTAssertFalse(de.templates.first!.applicableTo.contains(DayIndicator(day: .Wenesday, active: true)), "Wenesday is not anymore in week")
        XCTAssertTrue(de.templates.last!.applicableTo.contains(DayIndicator(day: .Wenesday, active: true)), "Wenesday is in weekend")
    }
}
