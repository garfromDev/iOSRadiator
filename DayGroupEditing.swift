//
//  DaylyEditing.swift
//  Radiator
//
//  Created by Stéphane FROMONT on 30/10/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import Foundation

struct DaylyEditing{
    var templates: [DayGroupEditing]
}

struct DayGroupEditing {
    var applicableTo : Set<Days> = Set<Days>()
    var template : DayTemplate = DayTemplate()
}

extension DaylyEditing{
    init(from wk:WeekCalendar){
        var provTemplates: [DayGroupEditing] = []
        for (days, dayCalendar) in wk {
            let newTemplate = DayTemplate(from: dayCalendar)
            if let index = provTemplates.map({$0.template}).firstIndex(of: newTemplate) {
                // this template is already listed, add this day to applicable days
                provTemplates[index].applicableTo.formUnion(Set(arrayLiteral: days))
            } else {
                // template not listed, add it for this day
                provTemplates.append(DayGroupEditing(applicableTo: Set(arrayLiteral: days),
                                                     template: newTemplate))
            }
        }
        self.init(templates: provTemplates)
    }
    
    func toCalendarObject()->CalendarObject {
        var wk = WeekCalendar()
        for template in templates{
            for day in template.applicableTo{
                wk[day] = DayCalendar.fromDayTemplate( template.template)
            }
        }
        return ["weekCalendar": wk]
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


