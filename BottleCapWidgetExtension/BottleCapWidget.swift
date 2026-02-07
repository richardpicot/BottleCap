//
//  BottleCapWidget.swift
//  BottleCapWidget
//
//  Widget entry point with timeline provider and configuration.
//

import SwiftUI
import WidgetKit

struct DrinkEntry: TimelineEntry {
    let date: Date
    let drinkCount: Double
    let drinkLimit: Double
}

struct Provider: TimelineProvider {
    private let suiteName = "group.co.richardp.BottleCap"

    func placeholder(in context: Context) -> DrinkEntry {
        DrinkEntry(date: Date(), drinkCount: 0, drinkLimit: 14)
    }

    func getSnapshot(in context: Context, completion: @escaping (DrinkEntry) -> Void) {
        let entry = readEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DrinkEntry>) -> Void) {
        let entry = readEntry()

        // Refresh at the next week boundary
        let refreshDate = nextWeekStart() ?? Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private func readEntry() -> DrinkEntry {
        let defaults = UserDefaults(suiteName: suiteName)
        let count = defaults?.double(forKey: "widgetDrinkCount") ?? 0
        let limit = defaults?.double(forKey: "widgetDrinkLimit") ?? 14
        return DrinkEntry(date: Date(), drinkCount: count, drinkLimit: limit)
    }

    private func nextWeekStart() -> Date? {
        let defaults = UserDefaults(suiteName: suiteName)
        let weekStartRaw = defaults?.string(forKey: "widgetWeekStartDay") ?? "monday"

        let calendar = Calendar.current
        let now = Date()

        // Convert weekday string to Calendar weekday int (1=Sunday, 2=Monday, etc.)
        let weekdayInt: Int
        switch weekStartRaw {
        case "sunday": weekdayInt = 1
        case "monday": weekdayInt = 2
        case "tuesday": weekdayInt = 3
        case "wednesday": weekdayInt = 4
        case "thursday": weekdayInt = 5
        case "friday": weekdayInt = 6
        case "saturday": weekdayInt = 7
        default: weekdayInt = 2
        }

        return calendar.nextDate(after: now, matching: DateComponents(weekday: weekdayInt), matchingPolicy: .nextTime)
    }
}

@main
struct BottleCapWidget: Widget {
    let kind = "BottleCapWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BottleCapWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Bottle Cap")
        .description("Track your weekly drinks.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    BottleCapWidget()
} timeline: {
    DrinkEntry(date: Date(), drinkCount: 3, drinkLimit: 14)
    DrinkEntry(date: Date(), drinkCount: 7, drinkLimit: 14)
}
