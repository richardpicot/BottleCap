//
//  DrinkDataService.swift
//  Bottle Cap
//
//  Static functions that transform raw drink data into grouped models.
//

import Foundation
import HealthKit

enum DrinkDataService {

    /// Aggregate HKQuantitySamples into per-day totals.
    static func dailyTotals(from samples: [HKQuantitySample]) -> [DailyDrinkTotal] {
        var drinksByDate: [Date: Double] = [:]

        for sample in samples {
            let date = sample.endDate.startOfDay
            let count = sample.quantity.doubleValue(for: HKUnit.count())
            drinksByDate[date, default: 0] += count
        }

        return drinksByDate.map { DailyDrinkTotal(date: $0.key, totalDrinks: $0.value) }
            .sorted { $0.date > $1.date }
    }

    /// Group daily totals into weekly totals based on the user's chosen week start day.
    static func weeklyTotals(from dailyTotals: [DailyDrinkTotal], weekStartDay: Weekday) -> [WeeklyDrinkTotal] {
        let calendar = Calendar.current
        var weekBuckets: [Date: [DailyDrinkTotal]] = [:]

        for daily in dailyTotals {
            guard let weekStart = calendar.date(toNearestOrLastWeekday: weekStartDay, matching: daily.date) else {
                continue
            }
            let normalizedWeekStart = weekStart.startOfDay
            weekBuckets[normalizedWeekStart, default: []].append(daily)
        }

        return weekBuckets.map { weekStart, days in
            WeeklyDrinkTotal(weekStart: weekStart, dailyTotals: days.sorted { $0.date > $1.date })
        }.sorted { $0.weekStart > $1.weekStart }
    }

    /// Group weekly totals into months, sorted newest-first.
    static func monthlyGroups(from weeklyTotals: [WeeklyDrinkTotal]) -> [MonthlyDrinkGroup] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"

        var monthBuckets: [String: (sortDate: Date, weeks: [WeeklyDrinkTotal])] = [:]

        for week in weeklyTotals {
            let monthKey = dateFormatter.string(from: week.weekStart)
            if monthBuckets[monthKey] == nil {
                monthBuckets[monthKey] = (sortDate: week.weekStart, weeks: [week])
            } else {
                monthBuckets[monthKey]!.weeks.append(week)
                // Keep the most recent date as sort date
                if week.weekStart > monthBuckets[monthKey]!.sortDate {
                    monthBuckets[monthKey]!.sortDate = week.weekStart
                }
            }
        }

        return monthBuckets.map { monthKey, data in
            MonthlyDrinkGroup(
                monthLabel: monthKey,
                sortDate: data.sortDate,
                weeks: data.weeks.sorted { $0.weekStart > $1.weekStart }
            )
        }.sorted { $0.sortDate > $1.sortDate }
    }

    /// Daily totals for the current week only.
    static func currentWeekDailyTotals(from dailyTotals: [DailyDrinkTotal], weekStartDay: Weekday) -> [DailyDrinkTotal] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(toNearestOrLastWeekday: weekStartDay, matching: Date()) else {
            return []
        }
        return dailyTotals
            .filter { $0.date >= startOfWeek.startOfDay }
            .sorted { $0.date > $1.date }
    }

    /// Monthly groups for all weeks before the current week.
    static func previousWeeksMonthlyGroups(from dailyTotals: [DailyDrinkTotal], weekStartDay: Weekday) -> [MonthlyDrinkGroup] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(toNearestOrLastWeekday: weekStartDay, matching: Date()) else {
            return []
        }
        let previousDays = dailyTotals.filter { $0.date < startOfWeek.startOfDay }
        let weeks = weeklyTotals(from: previousDays, weekStartDay: weekStartDay)
        return monthlyGroups(from: weeks)
    }
}
