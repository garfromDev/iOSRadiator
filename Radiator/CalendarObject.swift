import Foundation

enum Days:String, Codable{
    case monday
}
typealias Hours=String

enum Modes:String, Codable{
    case confort
    case eco
}

typealias DayCalendar = [Hours:Modes ]
typealias WeekCalendar = Dictionary<Days,DayCalendar>
typealias CalendarObject   = [String:WeekCalendar]
typealias CalendarName = String

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

