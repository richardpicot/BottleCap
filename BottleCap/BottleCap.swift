//
//  HealthKitAlcoholTestApp.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 06/10/2023.
//

import SwiftUI
import HealthKit

@main
struct BottleCap: App {
    @StateObject var healthKitManager = HealthKitManager()
    private let qaService = QAService.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKitManager)
                .environmentObject(qaService)
                .fontDesign(.rounded)
        }
    }
}
