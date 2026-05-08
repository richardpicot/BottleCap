//
//  LogDrinkOpenIntent.swift
//  BottleCap
//
//  Intents and configuration types for widgets and Control Center controls.
//  Target membership: both Bottle Cap and BottleCapWidgetExtension.
//

import AppIntents
import WidgetKit

// MARK: - Shared Week Helpers

/// Computes start-of-day for the most recent occurrence of the configured week start day.
/// Available to both the main app and widget extension (dual target membership).
func currentWeekStart(weekStartDay: String) -> Date {
    let calendar = Calendar.current
    let now = Date()

    let weekdayInt: Int
    switch weekStartDay {
    case "sunday": weekdayInt = 1
    case "monday": weekdayInt = 2
    case "tuesday": weekdayInt = 3
    case "wednesday": weekdayInt = 4
    case "thursday": weekdayInt = 5
    case "friday": weekdayInt = 6
    case "saturday": weekdayInt = 7
    default: weekdayInt = 2
    }

    let todayWeekday = calendar.component(.weekday, from: now)
    let daysBack = (todayWeekday - weekdayInt + 7) % 7
    let weekStart = calendar.date(byAdding: .day, value: -daysBack, to: now)!
    return calendar.startOfDay(for: weekStart)
}

/// Returns true if the stored week start timestamp is from a previous week.
func isWidgetCountStale(storedWeekStart: TimeInterval, weekStartDay: String) -> Bool {
    guard storedWeekStart > 0 else { return false } // no timestamp yet (pre-upgrade)
    let current = currentWeekStart(weekStartDay: weekStartDay)
    return storedWeekStart < current.timeIntervalSince1970
}

// MARK: - Shared Log-a-Drink Action

/// Optimistically increments the widget drink count and queues a pending log
/// for the main app to write to HealthKit. Used by both `LogDrinkIntent` (widget
/// plus button) and `LogDrinkOpenIntent` (Control Center control).
func logDrinkFromWidget() {
    let defaults = UserDefaults(suiteName: "group.co.richardp.BottleCap")!
    let weekStartDay = defaults.string(forKey: "widgetWeekStartDay") ?? "monday"

    var current = defaults.double(forKey: "widgetDrinkCount")
    let storedWeekStart = defaults.double(forKey: "widgetSyncedWeekStart")
    if isWidgetCountStale(storedWeekStart: storedWeekStart, weekStartDay: weekStartDay) {
        current = 0
        let newWeekStart = currentWeekStart(weekStartDay: weekStartDay)
        defaults.set(newWeekStart.timeIntervalSince1970, forKey: "widgetSyncedWeekStart")
    }

    defaults.set(current + 1, forKey: "widgetDrinkCount")

    var pending = defaults.array(forKey: "pendingDrinkLogs") as? [Double] ?? []
    pending.append(Date().timeIntervalSince1970)
    defaults.set(pending, forKey: "pendingDrinkLogs")

    WidgetCenter.shared.reloadAllTimelines()
}

// MARK: - Widget Configuration

enum WidgetPlusAction: String, AppEnum {
    case logADrink
    case logDrinks

    static var typeDisplayRepresentation = TypeDisplayRepresentation("Plus Button Action")
    static var caseDisplayRepresentations: [WidgetPlusAction: DisplayRepresentation] = [
        .logADrink: DisplayRepresentation("Log a Drink"),
        .logDrinks: DisplayRepresentation("Log Drinks..."),
    ]
}

struct BottleCapWidgetConfigIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configure Widget"
    static var description = IntentDescription("Choose what the plus button does.")

    @Parameter(title: "Plus button", default: .logADrink)
    var plusAction: WidgetPlusAction
}

// MARK: - Control Center: Log a Drink (opens app + logs one drink)

struct LogDrinkOpenIntent: OpenIntent {
    static var title: LocalizedStringResource = "Log a Drink"

    @Parameter(title: "Action")
    var target: LogDrinkTarget

    init() {
        self.target = .log
    }

    func perform() async throws -> some IntentResult {
        logDrinkFromWidget()
        return .result()
    }
}

enum LogDrinkTarget: String, AppEnum {
    case log

    static var typeDisplayRepresentation = TypeDisplayRepresentation("Log Action")
    static var caseDisplayRepresentations: [LogDrinkTarget: DisplayRepresentation] = [
        .log: DisplayRepresentation("Log a Drink"),
    ]
}

// MARK: - Control Center: Log Drinks... (opens app to log form)

struct OpenLogFormIntent: OpenIntent {
    static var title: LocalizedStringResource = "Log Drinks..."

    @Parameter(title: "Action")
    var target: OpenLogFormTarget

    init() {
        self.target = .openForm
    }

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.co.richardp.BottleCap")!
        defaults.set(true, forKey: "pendingShowLogForm")
        return .result()
    }
}

enum OpenLogFormTarget: String, AppEnum {
    case openForm

    static var typeDisplayRepresentation = TypeDisplayRepresentation("Open Log Form")
    static var caseDisplayRepresentations: [OpenLogFormTarget: DisplayRepresentation] = [
        .openForm: DisplayRepresentation("Log Drinks..."),
    ]
}

// MARK: - Control Center: Open Bottle Cap (just opens the app)

struct OpenAppIntent: OpenIntent {
    static var title: LocalizedStringResource = "Open Bottle Cap"

    @Parameter(title: "Action")
    var target: OpenAppTarget

    init() {
        self.target = .open
    }

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

enum OpenAppTarget: String, AppEnum {
    case open

    static var typeDisplayRepresentation = TypeDisplayRepresentation("Open App")
    static var caseDisplayRepresentations: [OpenAppTarget: DisplayRepresentation] = [
        .open: DisplayRepresentation("Open Bottle Cap"),
    ]
}
