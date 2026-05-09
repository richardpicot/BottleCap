//
//  LogDrinkIntent.swift
//  BottleCapWidget
//
//  AppIntent for the interactive plus button on the widget.
//

import AppIntents
import HealthKit
import WidgetKit

struct LogDrinkIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a Drink"
    static var description = IntentDescription("Log one drink")

    func perform() async throws -> some IntentResult {
        let now = Date()
        let defaults = UserDefaults(suiteName: "group.co.richardp.BottleCap")!

        // Optimistically update the widget's displayed count
        let weekStartDay = defaults.string(forKey: "widgetWeekStartDay") ?? "monday"
        var current = defaults.double(forKey: "widgetDrinkCount")
        let storedWeekStart = defaults.double(forKey: "widgetSyncedWeekStart")
        if isWidgetCountStale(storedWeekStart: storedWeekStart, weekStartDay: weekStartDay) {
            current = 0
            defaults.set(currentWeekStart(weekStartDay: weekStartDay).timeIntervalSince1970,
                         forKey: "widgetSyncedWeekStart")
        }
        defaults.set(current + 1, forKey: "widgetDrinkCount")

        // Write directly to HealthKit; only fall back to the queue if it fails
        if !(await writeToHealthKit(date: now)) {
            var pending = defaults.array(forKey: "pendingDrinkLogs") as? [Double] ?? []
            pending.append(now.timeIntervalSince1970)
            defaults.set(pending, forKey: "pendingDrinkLogs")
        }

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }

    private func writeToHealthKit(date: Date) async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: .numberOfAlcoholicBeverages) else { return false }
        let store = HKHealthStore()
        let sample = HKQuantitySample(
            type: sampleType,
            quantity: HKQuantity(unit: .count(), doubleValue: 1),
            start: date,
            end: date
        )
        do {
            try await store.save(sample)
            return true
        } catch {
            return false
        }
    }
}
