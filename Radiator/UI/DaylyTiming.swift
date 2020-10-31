//
//  DaylyTiming.swift
//  Radiator
//
//  Created by Alistef on 17/08/2020.
//  Copyright © 2020 garfromDev. All rights reserved.
//

import SwiftUI


/*
 A faire :vérifier qu'on peut afficher le controleur swift UI en ios13 et un controleur classique en iOS 9 (IPAD)
 
 si ça marche, définir les types
 créer les vues morceau par morceau :
 WeekDayView
 WeekView
 Mode
 Quarter
 FullDay
 */

// données de démo
let week = [DayIndicator(letter: "L", active: true),
            DayIndicator(letter: "M", active: true),
            DayIndicator(letter: "M", active: true),
            DayIndicator(letter: "J", active: true),
            DayIndicator(letter: "V", active: false),
            DayIndicator(letter: "S", active: true),
            DayIndicator(letter: "D", active: false)
]


extension HeatingMode {
    mutating func toogle(){
        switch self{
        case .confort:
            self = .eco
        case .eco:
            self = .confort
        default:
            break
        }
    }
}



@available(iOS 13, *) struct QuarterHourIndicator: View {
    @Binding var quarter: QuarterTemplate
    
    var body : some View {
        VStack{
            Button(action:{self.quarter.heatMode.toogle()}){
                if quarter.heatMode == .confort{
                    Text("🀫").fontWeight(.bold).foregroundColor(.red)
                }else{
                    Text("🀆").fontWeight(.bold).foregroundColor(.blue)
                }
            }
            Text(quarter.hour).font(.caption)
        }
    }
}


@available(iOS 13, *) struct Fill: View{
    @State var qh = QuarterTemplate(heatMode: .confort, hour: "08")
    var body: some View {
        // tenter forEach qhtab.enumerated()  index, qh in $qhtab[index]
        Group{
            QuarterHourIndicator(quarter: $qh)
            VStack{
                Button(action:{}){Text("🀫").fontWeight(.bold).foregroundColor(.red)}
                Text("  ").font(.caption)
            }
            VStack{
                Text("🀫").fontWeight(.bold).foregroundColor(.red)
                Text("  ").font(.caption)
            }
            VStack{
                Text("🀫").fontWeight(.bold).foregroundColor(.red)
                Text("  ").font(.caption)
            }
            VStack{
                Text("🀫").fontWeight(.bold).foregroundColor(.red)
                Text("  ").font(.caption)
            }
            VStack{
                Text("🀫").fontWeight(.bold).foregroundColor(.red)
                Text("  ").font(.caption)
            }
        }
    }
}

struct DayIndicator: Hashable{
    let letter: String
    var active: Bool
}


@available(iOS 13, *) struct WeekOverview: View {
   @State  var days: [DayIndicator]

var body: some View {
    
        HStack{
            ForEach(0..<7){jour in
                Button(action: {self.days[jour].active.toggle()}){
                    Text(self.days[jour].letter)
                        .foregroundColor(self.days[jour].active ? .black : .gray)}
                .font(.caption)
            }
        }
    }
}


@available(iOS 13, *) struct DaylyTiming: View {
    var dayGroup: DayGroupEditing
    var body: some View {
        VStack(alignment: .leading) {
            WeekOverview(days: week)
            Divider()
            ScrollView(.horizontal){
                HStack {
                    Fill()
                    Fill()
                }
            }
        }
        .padding()
    }
}


@available(iOS 13, *)
struct MultipleDayly: View {
    @EnvironmentObject var mng:UserInteractionManagerIos13
    
    var body: some View{
        VStack(alignment: .leading) {
            ForEach(mng.daylyEditing.templates, id:\.id){ dayGroup in
                DaylyTiming(dayGroup: dayGroup)
            }
        }
    }
}


@available(iOS 13, *) struct DaylyTiming_Previews: PreviewProvider {
    
    static var previews: some View {
        let mng = UserInteractionManagerIos13(distantFileManager: FTPfileUploader())
        return MultipleDayly().environmentObject(mng)
    }
}

@available(iOS, deprecated: 13.0, message: "Use swift UI") class DaylyTimingController: UIViewController {
    
}
