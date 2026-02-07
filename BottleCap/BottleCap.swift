//
//  BottleCap.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 06/10/2023.
//

import HealthKit
import SwiftUI

@main
struct BottleCap: App {
    @StateObject var healthKitManager = HealthKitManager()
    @StateObject var appSettings = AppSettings.shared
    private let qaService = QAService.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKitManager)
                .environmentObject(appSettings)
                .environmentObject(qaService)
        }
    }
}
