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
    @State private var navigateToDrinkCountView = false // Control navigatiorn
    
    var body: some Scene {
        WindowGroup {
            // Choose the appropriate view based on HealthKit authorization
            NavigationView {
                if navigateToDrinkCountView {
                    ContentView()
                } else {
                    WelcomeView(healthKitManager: healthKitManager, isPresented: $navigateToDrinkCountView)
                }
            }
            .environmentObject(healthKitManager)
            .onAppear {
                healthKitManager.checkHealthKitAuthorization { authorized in
                    navigateToDrinkCountView = authorized
                }
            }
        }
    }
}


