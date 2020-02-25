import Foundation
import UIKit

enum Days:String, Codable{
    case monday
    case tuesday
}
typealias Hours=String

enum Modes:String, Codable{
    case confort
    case eco
}

/** description of setting for a day
 keys are hours in 08:15 format, every 15 mn*/
typealias DayCalendar = [Hours:Modes ]

/** description of settings for the week
 keys are days in full english (monday, ...) */
typealias WeekCalendar = Dictionary<Days,DayCalendar>

/** encapsulation of weekCalendar for compatibility
 with python Radiator, only key is : weekCalendar
 this object can be encoded using JSON encoder and provide correct file format
 */
typealias CalendarObject   = [String:WeekCalendar]

/**
 calendar list is handled only by app, not by python, python will only use file
 week.json as input
 
 */
extension CalendarObject: jsonCodable{
    typealias T = CalendarObject
}

protocol jsonCodable: Codable{
    associatedtype T: Codable
    func toJson() -> Data
    /// factory method to create CalendarObject from json data
    static func fromJson(_ data: Data) -> T?
}

extension jsonCodable{
    func toJson() -> Data {
        let encoder = JSONEncoder()
        return  try! encoder.encode(self)
    }
    
    /// factory method to create CalendarObject from json data
    static func fromJson(_ data: Data) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from:data)
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

/// add DataSource capability
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

extension Calendars{
    override var debugDescription: String {
        var str = "current cal : \(currentCalendar)\n"
        for s in Array(list.keys) {
            str += "   \(s)\n"
        }
        return str
    }
}
