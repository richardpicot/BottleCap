//
//  ContentView.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 06/10/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var totalDrinks: Double = 0
    @State private var triggerHapticFeedback = false
    @State private var showWelcomeView: Bool = false
    @State private var showLogDrinksView = false
    @State private var showSettingsView = false
    @State private var showHistoryView = false
    @State private var startWeekDay: Int = Calendar.current.firstWeekday
    @State private var isPressed = false
    @State private var animationTrigger: Bool = false
    
    @ObservedObject var appSettings = AppSettings.shared
    @ObservedObject var healthKitManager = HealthKitManager()
    
    @Environment(\.colorScheme) var colorScheme
    
    private var drinksRemaining: Double {
        return max(0, appSettings.drinkLimit - totalDrinks)
    }
    
    private var formattedDrinksRemaining: String {
        let remaining = drinksRemaining
        return String(format: "%g", remaining)
    }
    
    private var drinksOverLimit: Double {
        let over = totalDrinks - appSettings.drinkLimit
        return max(over, 0)
    }
    
    private var formattedDrinksOverLimit: String {
        let over = drinksOverLimit
        return String(format: "%g", over)
    }
    
    private func updateTotalDrinks() {
        // Fetching drinks count based on the user's selected start of the week
        withAnimation {
            healthKitManager.readAlcoholData(startWeekDay: appSettings.weekStartDay) { (newTotal) in
                DispatchQueue.main.async {
                    self.totalDrinks = newTotal
                    self.animationTrigger.toggle()
                }
            }
        }
    }
    
    
    var body: some View {
        
        ZStack {
            // BACKGROUND
            BackgroundView(progress: CGFloat(totalDrinks) / CGFloat(appSettings.drinkLimit))
                .animation(.default, value: animationTrigger)
            
            VStack {
                Spacer()
                
                
                // COUNT
                Text("\(totalDrinks, specifier: "%.0f")")
                    .font(.system(size: 96))
                    .fontWeight(.medium)
                    .foregroundStyle(.inkPrimary)
                    .animation(.default, value: animationTrigger)
                    .contentTransition(.numericText(value: totalDrinks))
                    .onAppear {
                        animationTrigger.toggle()
                    }
                
                
                VStack {
                    Text(totalDrinks == 1 ? "Drink this week." : "Drinks this week.")
                    
                    if drinksRemaining > 0 {
                        Text("\(formattedDrinksRemaining) more until you reach your limit.")
                    } else if
                        totalDrinks == appSettings.drinkLimit {
                        Text("You've reached your limit.")
                    } else {
                        Text("You're \(formattedDrinksOverLimit) over your weekly limit.")
                    }
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.inkPrimary)
                .opacity(colorScheme == .dark ? 0.8 : 0.9)
                .multilineTextAlignment(.center)
                
                Spacer()
                
                
                // BUTTONS
                HStack {
                    Spacer()
                    
                    // Settings button
                    Button(action: {
                        showSettingsView = true
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.inkPrimary)
                    }
                    .sheet(isPresented: $showSettingsView) {
                        SettingsView(isPresented: $showSettingsView, appSettings: appSettings)
                            .presentationDetents([.medium, .large])
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .background(
                        .ultraThinMaterial
                    ).clipShape(Circle())
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            showLogDrinksView = true
                        }) {
                            Label("Log Multiple Drinks...", systemImage: "calendar.badge.plus")
                        }
                        
                        Button(action: {
                            healthKitManager.addAlcoholData(numberOfDrinks: 1, date: Date()) {
                                updateTotalDrinks()
                                triggerHapticFeedback.toggle()
                            }
                        }) {
                            Label("Log a Drink", systemImage: "plus.circle")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font((.system(size: 28)))
                            .foregroundStyle(.white)
                            .frame(minWidth: 72, minHeight: 72)
                            .background(.accentPrimary)
                            .clipShape(Circle())
                            .sheet(isPresented: $showLogDrinksView) {
                                LogDrinksView(isPresented: $showLogDrinksView) {
                                    healthKitManager.readAlcoholData(startWeekDay: appSettings.weekStartDay) { (newTotal) in
                                        DispatchQueue.main.async {
                                            self.totalDrinks = newTotal
                                        }
                                    }
                                }
                            }
                        
                        
                    }
                    .sensoryFeedback(trigger: triggerHapticFeedback) { oldValue, newValue in
                        totalDrinks >= appSettings.drinkLimit ? .warning : .success
                    }
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 6)
                    .shadow(color: .accentPrimary.opacity(0.15), radius: 20, x: 0, y: 6)
                    .scaleEffect(isPressed ? 0.85 : 1)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: isPressed)
                    
                    Spacer()
                    
                    
                    // History button
                    Button(action: {
                        showHistoryView = true
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.inkPrimary)
                    }
                    .sheet(isPresented: $showHistoryView) {
                        HistoryView()
                            .presentationDetents([.medium, .large])
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .background(
                        .ultraThinMaterial
                    ).clipShape(Circle())
                    
                    
                    Spacer()
                    
                    
                }
            }
            .onAppear {
                updateTotalDrinks()
                
                // Check HealthKit authorization
                healthKitManager.checkHealthKitAuthorization { isAuthorized in
                    if !isAuthorized {
                        // Show WelcomeView if HealthKit is not authorized
                        self.showWelcomeView = true
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
                    updateTotalDrinks()
                }
                
                
            }
        }
        .sheet(isPresented: $showWelcomeView) {
            // Display WelcomeView in sheet
            WelcomeView(healthKitManager: healthKitManager, isPresented: $showWelcomeView)
        }
        
        .onChange(of: appSettings.weekStartDay, initial: true) { oldState, newState in
            if oldState != newState {
                updateTotalDrinks()
            }
        }
    }
}

#Preview {
    ContentView()
}
