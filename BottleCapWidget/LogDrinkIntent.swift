//
//  LogDrinkIntent.swift
//  BottleCapWidget
//
//  AppIntent for the interactive plus button on the widget.
//

import AppIntents
import WidgetKit

struct LogDrinkIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a Drink"
    static var description = IntentDescription("Log one drink")

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.co.richardp.BottleCap")!

        // Optimistically increment displayed count
        let current = defaults.double(forKey: "widgetDrinkCount")
        defaults.set(current + 1, forKey: "widgetDrinkCount")

        // Queue pending log for main app to write to HealthKit
        var pending = defaults.array(forKey: "pendingDrinkLogs") as? [Double] ?? []
        pending.append(Date().timeIntervalSince1970)
        defaults.set(pending, forKey: "pendingDrinkLogs")

        // Reload widget timeline to reflect new count
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}
