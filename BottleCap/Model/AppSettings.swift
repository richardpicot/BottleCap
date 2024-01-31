//
//  AppSettings.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 23/10/2023.
//

import Foundation

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
    // Using Weekday enum to define the weekStartDay
    @Published var weekStartDay: Weekday {
        didSet {
            // Saving to UserDefaults
            UserDefaults.standard.set(weekStartDay.rawValue, forKey: "weekStartDay")
        }
    }
    
    @Published var drinkLimit: Double {
        didSet {
            // Saving to UserDefaults
            UserDefaults.standard.set(drinkLimit, forKey: "drinkLimit")
        }
    }
    
    @Published var hasShownLogDrinkForm: Bool {
        didSet {
            // Saving to UserDefaults
            UserDefaults.standard.set(hasShownLogDrinkForm, forKey: "hasShownLogDrinkForm")
        }
    }
    
    static let shared = AppSettings()
    
    
    public init() {
        // Initializing weekStartDay from UserDefaults
        if let savedWeekStartDay = UserDefaults.standard.string(forKey: "weekStartDay"),
           let weekday = Weekday(rawValue: savedWeekStartDay) {
            self.weekStartDay = weekday
        } else {
            self.weekStartDay = .monday // Default value
        }
        
        // Initialize drinkLimit from UserDefaults, with a default value of 6
        if let savedDrinkLimit = UserDefaults.standard.value(forKey: "drinkLimit") as? Double {
            self.drinkLimit = savedDrinkLimit
        } else {
            UserDefaults.standard.set(6, forKey: "drinkLimit") // Set default value in UserDefaults
            self.drinkLimit = 6 // Default value
        }
        
        // Initializing hasShownLogDrinkForm from UserDefaults
        self.hasShownLogDrinkForm = UserDefaults.standard.bool(forKey: "hasShownLogDrinkForm")
    
    }

}

