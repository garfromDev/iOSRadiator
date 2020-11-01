import Foundation
import UIKit

enum Days:String, Codable, CaseIterable{
    case Monday
    case Tuesday
    case Wenesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
    func ToLetter()->String {
        return [
            .Monday     : "L",
            .Tuesday    : "M",
            .Wenesday   : "M",
            .Thursday   : "J",
            .Friday     : "V",
            .Saturday   : "S",
            .Sunday     : "D"
        ][self]!
    }
}

extension Days: jsonCodable {
    typealias T = Days
}

typealias Hours=String


extension HeatingMode: jsonCodable{
    typealias T = HeatingMode
}

/** description of setting for a day
 keys are hours in 08:15 format, every 15 mn*/
typealias DayCalendar = [Hours:HeatingMode]
extension DayCalendar {
    static func fromDayTemplate(_  dt: DayTemplate)->DayCalendar{
        var dc = DayCalendar()
        dt.quarters.forEach({quarter in
            dc[quarter.hour as Hours] = quarter.heatMode
        })
        return dc
    }
}
/** description of settings for the week
 keys are days in full english (monday, ...) */
typealias WeekCalendar = [Days : DayCalendar]

/** encapsulation of weekCalendar for compatibility
 with python Radiator, only key is : weekCalendar
 this object can be encoded using JSON encoder and provide correct file format
 */
struct CalendarObject {
    // FIXME : a-t-on réelement besoind e CalendarObject?
    var weekCalendar: WeekCalendar
}
extension CalendarObject{
    func toJCalendarObject()->JCalendarObject{
        var wk : JWeekCalendar = [:]
        for (k, v) in self.weekCalendar {
            wk[k.rawValue as JDays] = v
        }
        return ["weekCalendar" : wk]
    }
}
/*
 To avoid the concern of dictionary with non string key encoded to array (even if it is enum with raw value String)
 we replace Days by JDays as String for encoding/decoding
 */
typealias JDays = String
typealias JWeekCalendar = [JDays : DayCalendar]
typealias JCalendarObject   = [String:JWeekCalendar]

/**
 calendar list is handled only by app, not by python, python will only use file
 week.json as input
 
 */
extension JCalendarObject: jsonCodable{
    typealias T = JCalendarObject
}

extension JCalendarObject{
    /**
     Transform JCalendarObject we get from Json into CalendarObject with strong type (enum)
     */
    func toCalendarObject()->CalendarObject {
        // FIXME : implement recuperation des templates ID
        var wk : WeekCalendar = [:]
        for (k, v) in self["weekCalendar"]! {
            if let day = Days(rawValue: k) {
                wk[day] = v
            }
        }
        return CalendarObject(weekCalendar: wk)
    }
    

}


typealias CalendarName = String
typealias FileName = String
/** contient tous les calendriers disponibles
*/
class Calendars:NSObject, Codable {
    var currentCalendar : CalendarName = ""
    var list : [CalendarName: FileName] = [:]
    var names : [String] {list.keys.map({$0})}
}

/// add create from export to json ability
extension Calendars: jsonCodable {
    typealias T = Calendars
}

//MARK:  add DataSource capability
extension Calendars: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    // TODO : this is not optimal, as this model method makes assumption about view definition
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellsID.calendarTableViewCell.rawValue)
        cell?.textLabel?.text = self.names[indexPath.row]
        cell?.isSelected = self.names[indexPath.row] == self.currentCalendar
        print("returning cell \(String(describing: cell?.textLabel?.text)) selected : \(String(describing: cell?.isSelected))")
        cell?.accessoryType = cell!.isSelected ? .checkmark : .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Calendrier en cours d'utilisation"
        }
        return ""
    }
}

// MARK: add debug description
extension Calendars{
    override var debugDescription: String {
        var str = "current cal : \(currentCalendar)\n"
        for s in Array(list.keys) {
            str += "   \(s)\n"
        }
        return str
    }
}
