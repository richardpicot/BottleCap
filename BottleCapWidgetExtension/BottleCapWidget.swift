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

    var formattedCount: String {
        let rounded = (drinkCount * 10).rounded() / 10
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", rounded)
        } else {
            return String(format: "%.1f", rounded)
        }
    }

    var isDecimal: Bool {
        let rounded = (drinkCount * 10).rounded() / 10
        return rounded.truncatingRemainder(dividingBy: 1) != 0
    }

    var wholePartString: String {
        String(format: "%.0f", floor((drinkCount * 10).rounded() / 10))
    }

    var decimalPartString: String {
        let rounded = (drinkCount * 10).rounded() / 10
        let fraction = rounded - floor(rounded)
        return String(format: ".%.0f", fraction * 10)
    }

    var progress: Double {
        guard drinkLimit > 0 else { return 0 }
        return min(drinkCount / drinkLimit, 1.0)
    }
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
struct BottleCapWidgetBundle: WidgetBundle {
    var body: some Widget {
        BottleCapWidget()
        LogDrinkShortcutWidget()
    }
}

struct BottleCapWidget: Widget {
    let kind = "BottleCapWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BottleCapWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Drinks This Week")
        .description("See your drinks logged throughout the week.")
        .supportedFamilies([.systemSmall, .accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

struct LogDrinkShortcutWidget: Widget {
    let kind = "LogDrinkShortcutWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
            LogDrinkShortcutView()
        }
        .configurationDisplayName("Log a Drink")
        .description("Tap to log a drink from your lock screen.")
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    BottleCapWidget()
} timeline: {
    DrinkEntry(date: Date(), drinkCount: 3, drinkLimit: 8)
    DrinkEntry(date: Date(), drinkCount: 10, drinkLimit: 8)
}

#Preview("Circular", as: .accessoryCircular) {
    BottleCapWidget()
} timeline: {
    DrinkEntry(date: Date(), drinkCount: 3, drinkLimit: 14)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    BottleCapWidget()
} timeline: {
    DrinkEntry(date: Date(), drinkCount: 7, drinkLimit: 14)
}

#Preview("Log Shortcut", as: .accessoryCircular) {
    LogDrinkShortcutWidget()
} timeline: {
    DrinkEntry(date: Date(), drinkCount: 0, drinkLimit: 14)
}
