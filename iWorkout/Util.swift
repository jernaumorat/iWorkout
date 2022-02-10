//
//  Util.swift
//  iWorkout
//
//  Created by Nathan on 31/1/22.
//

import Foundation
import SwiftUI

enum DayOfWeek : String, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

// Obtained from https://gist.github.com/edmund-h/2638e87bdcc26e3ce9fffc0aede4bdad
func generateRandomDate(daysBack: Int)-> Date?{
    let day = arc4random_uniform(UInt32(daysBack))+1
    let hour = arc4random_uniform(23)
    let minute = arc4random_uniform(59)
    
    let today = Date(timeIntervalSinceNow: 0)
    let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
    var offsetComponents = DateComponents()
    offsetComponents.day = -1 * Int(day - 1)
    offsetComponents.hour = -1 * Int(hour)
    offsetComponents.minute = -1 * Int(minute)
    
    let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
    return randomDate
}

func weightFormat(_ weight: Double) -> String {
    let frm = NumberFormatter()
    frm.numberStyle = .scientific
    frm.exponentSymbol = "e"
    frm.positiveFormat = "0.###E0kg"
    
    let weightStr =
        weight == 0 ? "Bodyweight" :
        weight < 1e5 ? String(format: "%.1fkg", weight) :
        frm.string(from: NSNumber(value: weight)) ?? "Very Heavy"
    
    return weightStr
}

func todayString() -> String {
    return DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
}

// Obtained from https://stackoverflow.com/a/69894162
public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter({
                $0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
        
    }
}

public extension Date {
    func begin() -> Date {
        return Calendar(identifier: .gregorian).startOfDay(for: self)
    }
    
    func end() -> Date {
        let cal = Calendar(identifier: .gregorian)
        return cal.date(byAdding: .nanosecond, value: -1, to: cal.date(byAdding: .day, value: 1, to: self.begin())!)!
    }
}
