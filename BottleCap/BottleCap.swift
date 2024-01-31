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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKitManager)
                .fontDesign(.rounded)
                .onOpenURL { url in
                    print("Received URL: \(url)")
                }
        }
    }
}


