//
//  ContentView.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 06/10/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var totalDrinks: Double = 0
    @State private var showWelcomeView: Bool = false
    @State private var showLogDrinksView = false
    @State private var showSettingsView = false
    @State private var showHistoryView = false
    @State private var startWeekDay: Int = Calendar.current.firstWeekday
    @State private var isPressed = false
    @State private var animationTrigger: Bool = false
    
    @ObservedObject var appSettings = AppSettings.shared
    @ObservedObject var healthKitManager = HealthKitManager()
    
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
                    .font(.system(size: 80))
                    .fontWeight(.semibold)
                    .foregroundStyle(.inkPrimary)
                    .animation(.default, value: animationTrigger)
                    .contentTransition(.numericText(value: totalDrinks))
                    .onAppear {
                        animationTrigger.toggle()
                    }
                
                
                VStack {
                    Text(totalDrinks == 1 ? "Drink this week" : "Drinks this week")
                    
                    if drinksRemaining > 0 {
                        Text("\(formattedDrinksRemaining) more until you reach your limit")
                    } else if
                        totalDrinks == appSettings.drinkLimit {
                        Text("You've reached your limit")
                    } else {
                        Text("You're \(formattedDrinksOverLimit) over your weekly limit")
                    }
                }
                .font(.body)
                .foregroundStyle(.inkPrimary)
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
                    .background(.backgroundTertiary)
                    .clipShape(Circle())
                    
                    Spacer()
                    
                    // Log drink button
                    Button {
                        // empty action
                    } label: {
                        Image(systemName: "plus")
                            .font((.system(size: 28)))
                            .foregroundStyle(.inkPrimaryFixed)
                    }
                    .simultaneousGesture(LongPressGesture().onChanged { _ in
                        print("Tap started")
                        isPressed = true
                    })
                    .simultaneousGesture(LongPressGesture().onEnded { _ in
                        print("Long press")
                        isPressed = false
                        showLogDrinksView = true
                    })
                    .simultaneousGesture(TapGesture().onEnded {
                        print("Button tap logged")
                        isPressed = false
                        healthKitManager.addAlcoholData(numberOfDrinks: 1, date: Date()) {
                            updateTotalDrinks()
                        }
                    })
                    .frame(minWidth: 72, minHeight: 72)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 10)
                    .shadow(color: .inkPrimary.opacity(0.05), radius: 20, x: 0, y: 10)
                    .scaleEffect(isPressed ? 0.85 : 1)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: isPressed)
                    .sheet(isPresented: $showLogDrinksView) {
                        LogDrinksView(isPresented: $showLogDrinksView) {
                            healthKitManager.readAlcoholData(startWeekDay: appSettings.weekStartDay) { (newTotal) in
                                DispatchQueue.main.async {
                                    self.totalDrinks = newTotal
                                }
                            }
                        }
                    }
                    
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
                    .background(.backgroundTertiary)
                    .clipShape(Circle())
                    
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
        .fontDesign(.rounded)
    }
}

#Preview {
    ContentView()
}
