//
//  DaylyEditing.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 30/10/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation

class DaylyEditing {
    var templates: [DayGroupEditing] = [] {
        didSet {
            print("setting DaylyEditing.templates")
            templates.forEach({t in t.daylyEditing = self})
        }
    }

    convenience init(from wk:WeekCalendar){
        //var provTemplates: [DayGroupEditing] = []
        self.init()
        for (days, dayCalendar) in wk {
            let newTemplate = DayTemplate(from: dayCalendar)
            if let index = self.templates.map({$0.dayTemplate}).firstIndex(of: newTemplate) {
                // this template is already listed, add this day to applicable days
                self.templates[index].addDay(day: days)
            } else {
                // template not listed, add it for this day
                self.templates.append(DayGroupEditing(applicableTo: DayIndicators.forDays([days]),
                                                      dayTemplate: newTemplate)
                )
            }
        }
    }
    
    /**
     A day has been added to a group
     remove this day from the others group
     */
    func addedDay(_ day:Days, to dayGroup :DayGroupEditing){
        for template in self.templates where template !== dayGroup {
            if let index = template.applicableTo.firstIndex(of: DayIndicator(day: day, active: true)){
                template.applicableTo[index].active = false  // set the day to inactive
            }
        }
    }
    
    func toCalendarObject()->CalendarObject {
        var wk = WeekCalendar()
        for template in templates{
            for day in template.applicableTo.filter({$0.active}) {
                wk[day.day] = DayCalendar.fromDayTemplate(template.dayTemplate)
            }
        }
        return CalendarObject(weekCalendar: wk)
    }
}


class DayGroupEditing: Identifiable {
    let id = UUID()
    var applicableTo : DayIndicators
    var dayTemplate : DayTemplate = DayTemplate()
    var daylyEditing: DaylyEditing!
    
    init(applicableTo : DayIndicators, dayTemplate : DayTemplate){
        self.applicableTo = applicableTo
        self.dayTemplate = dayTemplate
    }
    
    
    /** make this DayGroupEditing applicable to this day in addition of already applicables days
      NOTE : could use didset and before/after comparison instead of AddDay()
     */
    @discardableResult func addDay(day: Days)->DayGroupEditing{
        if let index = self.applicableTo.firstIndex(where: {$0.day == day}){
            self.applicableTo[index].active = true
        }else{  // not used because we initialize DayIndicators with full days, but better be sure
            self.applicableTo.append(DayIndicator(day: day, active: true))
        }
        daylyEditing?.addedDay(day, to: self)
        return self  // for chaining
    }
}


typealias DayIndicators = [DayIndicator]
extension DayIndicators {
    /** return DayIndicator with this day activated */
    static func forDays(_ days:Set<Days>)->DayIndicators {
        return Days.allCases.map {
            cday in DayIndicator(day: cday,
                                 active: days.contains(cday))
        }
    }
}


struct DayIndicator: Hashable{
    let day: Days
    var active: Bool
}

struct DayTemplate: Equatable {
    var quarters : Array<QuarterTemplate> = []
}
extension DayTemplate{
    init(from  dc: DayCalendar){
        var quarters : Array<QuarterTemplate> = []
        for(hour, mode) in dc{
            quarters.append(QuarterTemplate(heatMode: mode, hour: hour))
        }
        self.init(quarters: quarters.sorted())
    }
}


struct QuarterTemplate: Equatable, Comparable {
    var heatMode : HeatingMode
    var hour: String = ""
    static func < (lhs: QuarterTemplate, rhs: QuarterTemplate) -> Bool {
        return lhs.hour < rhs.hour
    }
}
