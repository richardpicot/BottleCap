//
//  DrinkData.swift
//  Bottle Cap
//
//  Data model structs for drink tracking.
//

import Foundation

struct DailyDrinkTotal: Identifiable {
    let date: Date
    let totalDrinks: Double

    var id: Date { date }
}

struct WeeklyDrinkTotal: Identifiable {
    let weekStart: Date
    let dailyTotals: [DailyDrinkTotal]

    var id: Date { weekStart }

    var totalDrinks: Double {
        dailyTotals.reduce(0) { $0 + $1.totalDrinks }
    }
}

struct MonthlyDrinkGroup: Identifiable {
    let monthLabel: String
    let sortDate: Date
    let weeks: [WeeklyDrinkTotal]

    var id: String { monthLabel }
}
