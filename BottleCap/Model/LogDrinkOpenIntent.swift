//
//  LogDrinkOpenIntent.swift
//  BottleCap
//
//  Intents and configuration types for widgets and Control Center controls.
//  Target membership: both Bottle Cap and BottleCapWidgetExtension.
//

import AppIntents
import WidgetKit

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
        let defaults = UserDefaults(suiteName: "group.co.richardp.BottleCap")!

        // Optimistically increment displayed count
        let current = defaults.double(forKey: "widgetDrinkCount")
        defaults.set(current + 1, forKey: "widgetDrinkCount")

        // Queue pending log for main app to write to HealthKit
        var pending = defaults.array(forKey: "pendingDrinkLogs") as? [Double] ?? []
        pending.append(Date().timeIntervalSince1970)
        defaults.set(pending, forKey: "pendingDrinkLogs")

        WidgetCenter.shared.reloadAllTimelines()

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
