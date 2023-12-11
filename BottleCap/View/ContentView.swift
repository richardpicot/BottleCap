//
//  ContentView.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 06/10/2023.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var totalDrinks: Double = 0
    @State private var triggerHapticFeedback = false
    @State private var showLogDrinksView = false
    @State private var showSettingsView = false
    @State private var showHistoryView = false
    @State private var startWeekDay: Int = Calendar.current.firstWeekday
    @State private var isPressed = false
    @State private var animationTrigger: Bool = false
    
    @AppStorage("processCompletedCount") var processCompletedCount = 0
    @AppStorage("lastVersionPromptedForReview") var lastVersionPromptedForReview = ""
    
    @ObservedObject var appSettings = AppSettings.shared
    @ObservedObject var healthKitManager = HealthKitManager()
    
    //Onboarding
    @State private var isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
    @State private var showWelcomeView = false
    @State private var showAlert = false
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.requestReview) private var requestReview
    
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
    
    private func logDrink() {
        healthKitManager.addAlcoholData(numberOfDrinks: 1, date: Date()) {
            DispatchQueue.main.async {
                updateTotalDrinks()
                processCompletedCount += 1
                checkAndPresentReviewRequest()
                triggerHapticFeedback.toggle()
            }
        }
    }
    
    
    private func updateTotalDrinks() {
        withAnimation {
            healthKitManager.readAlcoholData(startWeekDay: appSettings.weekStartDay) { newTotal in
                DispatchQueue.main.async {
                    self.totalDrinks = newTotal
                    self.animationTrigger.toggle()
                }
            }
        }
    }
    
    private func checkAndPresentReviewRequest() {
        let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        if processCompletedCount >= 4, currentAppVersion != lastVersionPromptedForReview {
            presentReview()
            lastVersionPromptedForReview = currentAppVersion
        }
    }
    
    private func presentReview() {
        Task {
            // Delay for two seconds to avoid interrupting the user
            try await Task.sleep(for: .seconds(1))
            requestReview() // No 'await' needed
        }
    }
    
    private func checkHealthKitAuthorization() {
        healthKitManager.checkHealthKitAuthorization { status in
            switch status {
            case .authorized: break // Normal functionality
            case .notDetermined:
                // Handle first-time access, potentially showing WelcomeView
                showWelcomeView = true
            case .denied:
                // HealthKit access was previously denied; show alert
                showAlert = true
            }
        }
    }
    
    private func generateHapticFeedback() {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        
        if totalDrinks >= appSettings.drinkLimit {
            feedbackGenerator.notificationOccurred(.error)
            print("Error haptic played")
        } else {
            feedbackGenerator.notificationOccurred(.success)
            print("Success haptic played")
        }
    }
    
    
    var body: some View {
        GeometryReader { geometry in // Used to check for home button
            NavigationView {
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
                                .buttonBorderShape(.circle)
                            
                            Spacer()
                            
                            Menu {
                                Button(action: {
                                    checkHealthKitAuthorization()
                                    showLogDrinksView = true
                                }) {
                                    Label("Log Multiple Drinks...", systemImage: "calendar.badge.plus")
                                }
                                
                                Button(action: {
                                    checkHealthKitAuthorization()
                                    logDrink()
                                }) {
                                    Label("Log a Drink", systemImage: "plus.circle")
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .font((.system(size: 28)))
                                    .foregroundStyle(.white)
                                    .frame(minWidth: 72, minHeight: 72)
                                    .background(.accentPrimary)
                                    .buttonBorderShape(.circle)
                                    .clipShape(Circle())
                                    .sheet(isPresented: $showLogDrinksView) {
                                        LogDrinksView(
                                            isPresented: $showLogDrinksView,
                                            logDrinkClosure: { numberOfDrinks, date in
                                                healthKitManager.addAlcoholData(numberOfDrinks: numberOfDrinks, date: date) {
                                                    DispatchQueue.main.async {
                                                        updateTotalDrinks()
                                                        processCompletedCount += 1
                                                        checkAndPresentReviewRequest()
                                                    }
                                                }
                                            },
                                            totalDrinks: totalDrinks,
                                            drinkLimit: appSettings.drinkLimit
                                        )
                                    }
                                
                                
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
                                .buttonBorderShape(.circle)
                            
                            
                            
                            Spacer()
                            
                            
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom < 20 ? 20 : 0) // Inset on devices with a home button
                    }
                }
            }
            .onAppear {
                updateTotalDrinks()
                checkHealthKitAuthorization()
            }
            .onChange(of: triggerHapticFeedback) { oldValue, newValue in
                generateHapticFeedback()
            }
            .sheet(isPresented: $showWelcomeView) {
                WelcomeView(healthKitManager: healthKitManager, isPresented: $showWelcomeView)
                    .interactiveDismissDisabled()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Health Access Denied"),
                    message: Text("Please enable HealthKit access in Settings."),
                    dismissButton: .default(Text("Open Settings"), action: {
                        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    })
                )
            }
            .onChange(of: appSettings.weekStartDay, initial: true) { oldState, newState in
                if oldState != newState {
                    updateTotalDrinks()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                updateTotalDrinks()
            }
        }
    }
}

#Preview {
    ContentView()
}
