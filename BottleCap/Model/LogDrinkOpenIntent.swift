//
//  LogDrinkOpenIntent.swift
//  BottleCap
//
//  OpenIntent for Control Center control that opens the app and logs a drink.
//  Target membership: both Bottle Cap and BottleCapWidgetExtension.
//

import AppIntents
import WidgetKit

enum LogDrinkTarget: String, AppEnum {
    case log

    static var typeDisplayRepresentation = TypeDisplayRepresentation("Log Action")
    static var caseDisplayRepresentations: [LogDrinkTarget: DisplayRepresentation] = [
        .log: DisplayRepresentation("Log a Drink"),
    ]
}

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
