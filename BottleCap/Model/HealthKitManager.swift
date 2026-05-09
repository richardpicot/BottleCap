//
//  HealthKitManager.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 06/10/2023.
//

import HealthKit
import WidgetKit

@MainActor
class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()

    @Published var isHealthDataAvailable: Bool = false

    enum HealthKitAuthorizationStatus {
        case authorized
        case notDetermined
        case denied
    }

    // Checks the authorization status of HealthKit
    func checkHealthKitAuthorization() -> HealthKitAuthorizationStatus {
        let drinkType = HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!
        let status = healthStore.authorizationStatus(for: drinkType)

        switch status {
        case .notDetermined:
            return .notDetermined
        case .sharingDenied:
            return .denied
        case .sharingAuthorized:
            return .authorized
        @unknown default:
            return .denied
        }
    }

    // Requests permissions for HealthKit
    func requestHealthKitPermission() async throws {
        let readTypes: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!]
        let writeTypes: Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!]

        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
        self.isHealthDataAvailable = true
        print("Permission granted")
    }

    func readAlcoholData(startWeekDay: Weekday) async -> Double {
        let calendar = Calendar.current
        let now = Date()

        guard let closestPastWeekday = calendar.date(toNearestOrLastWeekday: startWeekDay, matching: now) else {
            return 0
        }

        let startOfWeek = calendar.startOfDay(for: closestPastWeekday)

        print("Updated startOfWeek: \(startOfWeek), closestPastWeekday: \(closestPastWeekday)")

        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: now, options: .strictStartDate)
        let sampleType = HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, _ in
                var totalDrinks = 0.0
                if let results = results as? [HKQuantitySample] {
                    for sample in results {
                        totalDrinks += sample.quantity.doubleValue(for: HKUnit.count())
                    }
                }
                continuation.resume(returning: totalDrinks)
            }

            print("Calculated startOfWeek: \(startOfWeek), closestPastWeekday: \(closestPastWeekday)")
            healthStore.execute(query)
        }
    }

    func addAlcoholData(numberOfDrinks: Double, date: Date) async throws {
        let quantity = HKQuantity(unit: HKUnit.count(), doubleValue: numberOfDrinks)
        let sampleType = HKQuantityType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!
        let sample = HKQuantitySample(type: sampleType, quantity: quantity, start: date, end: date)

        try await healthStore.save(sample)
        print("Successfully saved data")
    }

    func readAllAlcoholEntries() async -> [HKQuantitySample] {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.numberOfAlcoholicBeverages) else {
            print("The numberOfAlcoholicBeverages type is not available")
            return []
        }

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, results, _ in
                if let results = results as? [HKQuantitySample] {
                    continuation.resume(returning: results)
                } else {
                    continuation.resume(returning: [])
                }
            }

            healthStore.execute(query)
        }
    }

    func deleteAlcoholData(sample: HKQuantitySample) async throws {
        try await healthStore.delete(sample)
        print("Successfully deleted alcohol data")
    }

    // MARK: - Widget Support

    func processPendingWidgetLogs() async {
        let defaults = UserDefaults(suiteName: AppSettings.suiteName)!
        guard let pending = defaults.array(forKey: "pendingDrinkLogs") as? [Double], !pending.isEmpty else { return }

        var failed: [Double] = []
        for timestamp in pending {
            let date = Date(timeIntervalSince1970: timestamp)
            do {
                try await addAlcoholData(numberOfDrinks: 1, date: date)
            } catch {
                failed.append(timestamp)
            }
        }

        if failed.isEmpty {
            defaults.removeObject(forKey: "pendingDrinkLogs")
        } else {
            defaults.set(failed, forKey: "pendingDrinkLogs")
        }
    }

    func deleteAlcoholDataForDate(_ date: Date) async throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let sampleType = HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)!

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.deleteObjects(of: sampleType, predicate: predicate) { _, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        await syncWidgetData()
    }

    func syncWidgetData() async {
        let defaults = UserDefaults(suiteName: AppSettings.suiteName)
        let weekStartRaw = defaults?.string(forKey: "widgetWeekStartDay") ?? "monday"
        let weekday = Weekday(rawValue: weekStartRaw) ?? .monday
        let total = await readAlcoholData(startWeekDay: weekday)
        defaults?.set(total, forKey: "widgetDrinkCount")
        let weekStart = currentWeekStart(weekStartDay: weekStartRaw)
        defaults?.set(weekStart.timeIntervalSince1970, forKey: "widgetSyncedWeekStart")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
