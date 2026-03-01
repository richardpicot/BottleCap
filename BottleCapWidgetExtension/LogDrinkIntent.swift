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
        logDrinkFromWidget()
        return .result()
    }
}