//
//  CalendarExtensions.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 23/10/2023.
//

import Foundation

extension Calendar {
    func date(toNearestOrLastWeekday weekday: Weekday, matching date: Date) -> Date? {
        let weekdayInt = weekday.rawValue.capitalized
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        for dayOffset in 0...6 {
            if let newDate = self.date(byAdding: .day, value: -dayOffset, to: date),
               dateFormatter.string(from: newDate) == weekdayInt {
                return newDate
            }
        }
        
        return nil
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

