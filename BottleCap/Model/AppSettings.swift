//
//  AppSettings.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 23/10/2023.
//

import Foundation
import WidgetKit

extension AppSettings {
    static var preview: AppSettings {
        let instance = AppSettings()
        // Configure the instance if needed
        return instance
    }
}

enum Weekday: String, CaseIterable, Identifiable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday

    var id: String { self.rawValue }
    var displayName: String { self.rawValue.capitalized }
}

class AppSettings: ObservableObject {
    static let suiteName = "group.co.richardp.BottleCap"

    private let defaults: UserDefaults

    // Using Weekday enum to define the weekStartDay
    @Published var weekStartDay: Weekday {
        didSet {
            defaults.set(weekStartDay.rawValue, forKey: "weekStartDay")
            defaults.set(weekStartDay.rawValue, forKey: "widgetWeekStartDay")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    @Published var drinkLimit: Double {
        didSet {
            defaults.set(drinkLimit, forKey: "drinkLimit")
            defaults.set(drinkLimit, forKey: "widgetDrinkLimit")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    @Published var hasShownLogDrinkForm: Bool {
        didSet {
            defaults.set(hasShownLogDrinkForm, forKey: "hasShownLogDrinkForm")
        }
    }

    static let shared = AppSettings()


    public init() {
        let sharedDefaults = UserDefaults(suiteName: AppSettings.suiteName) ?? UserDefaults.standard
        self.defaults = sharedDefaults

        // One-time migration from standard UserDefaults to shared suite
        if !sharedDefaults.bool(forKey: "didMigrateToAppGroup") {
            let standard = UserDefaults.standard
            if let weekStart = standard.string(forKey: "weekStartDay") {
                sharedDefaults.set(weekStart, forKey: "weekStartDay")
            }
            if standard.object(forKey: "drinkLimit") != nil {
                sharedDefaults.set(standard.double(forKey: "drinkLimit"), forKey: "drinkLimit")
            }
            if standard.object(forKey: "hasShownLogDrinkForm") != nil {
                sharedDefaults.set(standard.bool(forKey: "hasShownLogDrinkForm"), forKey: "hasShownLogDrinkForm")
            }
            sharedDefaults.set(true, forKey: "didMigrateToAppGroup")
        }

        // Initializing weekStartDay from shared defaults
        if let savedWeekStartDay = sharedDefaults.string(forKey: "weekStartDay"),
           let weekday = Weekday(rawValue: savedWeekStartDay) {
            self.weekStartDay = weekday
        } else {
            self.weekStartDay = .monday // Default value
        }

        // Initialize drinkLimit from shared defaults, with a default value of 6
        if sharedDefaults.object(forKey: "drinkLimit") != nil {
            self.drinkLimit = sharedDefaults.double(forKey: "drinkLimit")
        } else {
            sharedDefaults.set(6, forKey: "drinkLimit")
            self.drinkLimit = 6
        }

        // Initializing hasShownLogDrinkForm from shared defaults
        self.hasShownLogDrinkForm = sharedDefaults.bool(forKey: "hasShownLogDrinkForm")
    }

}
