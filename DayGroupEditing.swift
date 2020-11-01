//
//  DaylyEditing.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 30/10/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation

struct DaylyEditing {
    var templates: [DayGroupEditing] = [] {
        didSet {
            print("setting DaylyEditing.templates")
        }
    }
}

extension DaylyEditing{
    init(from wk:WeekCalendar){
        var provTemplates: [DayGroupEditing] = []
        for (days, dayCalendar) in wk {
            let newTemplate = DayTemplate(from: dayCalendar)
            if let index = provTemplates.map({$0.dayTemplate}).firstIndex(of: newTemplate) {
                // this template is already listed, add this day to applicable days
                provTemplates[index].addDay(day: days)
            } else {
                // template not listed, add it for this day
                provTemplates.append(DayGroupEditing(applicableTo: Set(arrayLiteral: days),
                                                     template: newTemplate))
            }
        }
        self.init(templates: provTemplates)
    }
    
    func toCalendarObject()->CalendarObject {
        // FIXME : ajouter generation des template IDS
        var wk = WeekCalendar()
        for template in templates{
            for day in template.applicableTo{
                //wk[day.] = DayCalendar.fromDayTemplate( template.template)
            }
        }
        return CalendarObject(weekCalendar: wk)
    }
}


struct DayIndicator: Hashable{
    let day: Days
    var active: Bool
}

// crerr un type pour [DaysIndicator] ou une extension de Array pour ce type

struct DayGroupEditing: Identifiable {
    let id = UUID()
    var applicableTo : [DayIndicator]
    var dayTemplate : DayTemplate = DayTemplate()
    @discardableResult mutating func addDay(day: Days)->DayGroupEditing{
        if let index = self.applicableTo.firstIndex(where: {$0.day == day}){
            self.applicableTo[index].active = true
        } // FIXME: vérifier les initialisations, il faut que tous les days existent dans les dayIndicator
    }
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
        self.init(quarters: quarters)
    }
}


struct QuarterTemplate: Equatable {
    var heatMode : HeatingMode
    var hour: String = ""
}


