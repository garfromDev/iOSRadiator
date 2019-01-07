
enum Days:String{
  case monday = "Monday"
}
typealias Hours=String
enum Modes:String{
  case confort = "confort"
}
typealias DayCalendar = [Hours:Modes ]

typealias WeekCalendar=[Days:DayCalendar]

struct Calendar:Codable{
  var weekCalendar : WeekCalendar
  public init(from decoder: Decoder) throws{}
}

let a=Calendar(weekCalendar:[.monday:["00":.confort]])
