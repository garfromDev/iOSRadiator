import Foundation
import UIKit

/*
 JSON -> JCalendarObjetc -> CalendarObject -> DaylyEditings  : use natural decoding
 DaylyEditings -> CalendarObject -> JSON  : use custome encoding to keek days and hours in order
 */

enum Days:String, Codable, CaseIterable{
    case Monday
    case Tuesday
    case Wenesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
    
    var sequence: Int {
        switch self{
        case .Monday:
            return 1
        case .Tuesday:
            return 2
        case .Wenesday:
            return 3
        case .Thursday:
            return 4
        case .Friday:
            return 5
        case .Saturday:
            return 6
        case .Sunday:
            return 7
        }
    }
    
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

extension Days : Comparable {
    static func < (lhs: Days, rhs: Days) -> Bool {
        return lhs.sequence < rhs.sequence
    }
}

extension Days: jsonCodable {
    typealias T = Days
}

typealias Hours=String
extension Hours {
    func toMinutes()->Int{
        return self.split(separator: ":").map({Int($0)!}).reduce(0) { (a, b) in a * 60 + b
        }
    }
    
    static func < (lhs: Hours, rhs: Hours) -> Bool {
        return lhs.toMinutes() < rhs.toMinutes()
    }
}

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
    func toJson() -> Data {
        // custom implementation to keep hour ordered even if dict has no order
        var result = "{\n"
        for hour in self.keys.sorted(){
            result += "\"\(hour)\" : \"\(self[hour]!.rawValue)\",\n"
        }
        result += "}"
        return result.data(using: .utf8)!
    }
}
/** description of settings for the week
 keys are days in full english (monday, ...) */
typealias WeekCalendar = [Days : DayCalendar]
extension WeekCalendar {
    func toJson()->Data{
        var result = "{\n"
        for day in self.keys.sorted(){
            result += """
            "\(day.rawValue)" : \(String(data: self[day]!.toJson(), encoding:.utf8)!),\n
            """
        }
        result += "}"
        return result.data(using: .utf8)!
    }
}
/** encapsulation of weekCalendar for compatibility
 with python Radiator, only key is : weekCalendar
 this object can be encoded using JSON encoder and provide correct file format
 */
struct CalendarObject: Dated {
    internal var lastChangeDate : Date = Date.distantPast
    var weekCalendar: WeekCalendar {
        didSet {
            lastChangeDate = Date()
        }
    }
}
extension CalendarObject{
    func toJCalendarObject()->JCalendarObject{
        var wk : JWeekCalendar = [:]
        for k in self.weekCalendar.sorted(by: {d1, d2 in d1.key < d2.key}) {
            wk[k.key.rawValue as JDays] = self.weekCalendar[k.key]
        }
        return ["weekCalendar" : wk]
    }
}

extension CalendarObject: jsonEncodable{
    typealias T = CalendarObject
    func toJson()->Data{
        var result = """
        {"weekCalendar" :
        """
        result += String(data: self.weekCalendar.toJson(), encoding: .utf8)!
        result += "}"
        return result.data(using: .utf8)!
    }
}
extension CalendarObject: JsonDated {}

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
extension JCalendarObject: jsonCodable, jsonEncodable, jsonDecodable{
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
        return CalendarObject(lastChangeDate: Date(), weekCalendar: wk)
    }
}


typealias CalendarName = String
typealias FileName = String
/** contient tous les calendriers disponibles
*/
class Calendars:NSObject, Codable, Dated {
    internal var lastChangeDate : Date = Date()  //TODO: vérifier si il faut initialiser dans le passé
    var currentCalendar : CalendarName = "" {
        didSet {
            lastChangeDate = Date()
        }
    }
    var list : [CalendarName: FileName] = [:] {
        didSet {
            lastChangeDate = Date()
        }
    }
    var names : [String] {list.keys.map({$0})}
}


/// add create from export to json ability
extension Calendars: jsonCodable {
    typealias T = Calendars
}

extension Calendars: JsonDated {}


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
