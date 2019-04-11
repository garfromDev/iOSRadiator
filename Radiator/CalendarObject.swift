import Foundation

enum Days:String, Codable{
    case monday
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
 with python Radiatir, only key is : weekCalendar
 */
typealias CalendarObject   = [String:WeekCalendar]
typealias CalendarName = String

/** contient tous les calendriers disponibles
*/
struct Calendars:Codable {
    var currentCalendar : String
    var list : [CalendarName:CalendarObject]
    init(){
        currentCalendar=""
        list=[:] 
    }
}


extension Calendars{
    func toJson() -> Data {
        let encoder = JSONEncoder()
        let data =  try! encoder.encode(self)
        return data
    }
}





func test(){
    let t=["weekCalendar":["monday" : ["00":.confort,"015":.eco] as DayCalendar]]
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data =  try! encoder.encode(t)
    let result = String(data:data, encoding:.utf8)
    print(result!)
}

