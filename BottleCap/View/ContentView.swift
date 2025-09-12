//
//  ContentView.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 06/10/2023.
//

import StoreKit
import SwiftUI

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

    // Onboarding
    @State private var showWelcomeView = false
    @State private var showHealthAccessView = false
    @State private var showAlert = false
    @State private var isShowingMenu = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.requestReview) private var requestReview

    // Homescreen quick action
    @EnvironmentObject var qaService: QAService
    @Environment(\.scenePhase) var scenePhase

    private func splitFormattedTotalDrinks() -> (String, String) {
        let formattedString = String(format: "%.1f", totalDrinks)
        let components = formattedString.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)

        if components.count == 2 && components[1] == "0" {
            return (components[0], "")
        } else if components.count == 2 {
            return (components[0], components[1])
        } else {
            return (formattedString, "")
        }
    }

    private var drinksRemaining: Double {
        let roundedTotal = NumberFormatterUtility.roundedValue(totalDrinks)
        return max(0, appSettings.drinkLimit - roundedTotal)
    }

    private var formattedDrinksRemaining: String {
        return NumberFormatterUtility.formatRounded(drinksRemaining)
    }

    private var drinksOverLimit: Double {
        let over = totalDrinks - appSettings.drinkLimit
        return max(over, 0)
    }

    private var formattedDrinksOverLimit: String {
        return NumberFormatterUtility.formatRounded(drinksOverLimit)
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
            try await Task.sleep(for: .seconds(1))
            requestReview()
        }
    }

    private func checkHealthKitAuthorization() {
        healthKitManager.checkHealthKitAuthorization { status in
            switch status {
            case .authorized: break
            case .notDetermined:
                showWelcomeView = true
            case .denied:
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

    private func handleLogMultipleDrinksAction() {
        healthKitManager.checkHealthKitAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.showLogDrinksView = true
                case .notDetermined:
                    self.showHealthAccessView = true
                case .denied:
                    self.showAlert = true
                }
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    BackgroundView(progress: CGFloat(NumberFormatterUtility.roundedValue(totalDrinks)) / CGFloat(appSettings.drinkLimit))
                        .animation(.default, value: animationTrigger)

                    VStack {
                        Spacer()
                        let (integerPart, decimalPart) = splitFormattedTotalDrinks()

                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text(integerPart)
                                .font(.system(size: 96))
                                .fontWeight(.medium)
                                .foregroundStyle(.textPrimary)
                                .animation(.default, value: animationTrigger)
                                .contentTransition(.numericText(value: totalDrinks))

                            if !decimalPart.isEmpty {
                                Text(".\(decimalPart)")
                                    .font(.system(size: 56))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.textPrimary)
                                    .animation(.default, value: animationTrigger)
                                    .contentTransition(.numericText(value: totalDrinks))
                            }
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                        VStack {
                            Text(NumberFormatterUtility.roundedValue(totalDrinks) == 1 ? "Drink this week." : "Drinks this week.")
                            if drinksRemaining > 0 {
                                Text("\(formattedDrinksRemaining) more until you reach your limit.")
                            } else if
                                NumberFormatterUtility.roundedValue(totalDrinks) == appSettings.drinkLimit
                            {
                                Text("You've reached your limit.")
                            } else {
                                Text("You're \(formattedDrinksOverLimit) over your weekly limit.")
                            }
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.textPrimary)
                        .opacity(colorScheme == .dark ? 0.8 : 0.9)
                        .multilineTextAlignment(.center)

                        Spacer()

                        // BUTTONS
                        HStack {
                            Spacer()

                            // Settings button
                            Group {
                                if #available(iOS 26, *) {
                                    Image(systemName: "gear")
                                        .font(.system(size: 18, weight: .semibold))
                                        .opacity(isShowingMenu ? 0.2 : 1.0)
                                        .animation(.smooth(duration: 0.3), value: isShowingMenu)
                                        .frame(width: 44, height: 44)
                                        .glassEffect(.regular.tint(Color.fillTertiary).interactive())
                                        .onTapGesture {
                                            if !isShowingMenu {
                                                showSettingsView = true
                                            }
                                        }
                                } else {
                                    Button("Settings", systemImage: "gear") {
                                        showSettingsView = true
                                    }
                                    .labelStyle(.iconOnly)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.textPrimary)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .background(
                                        Circle()
                                            .fill(colorScheme == .dark ? Color.fillTertiary.opacity(0.6) : Color.fillTertiary)
                                    )
                                    .clipShape(Circle())
                                    .buttonBorderShape(.circle)
                                }
                            }
                            .sheet(isPresented: $showSettingsView) {
                                SettingsView(isPresented: $showSettingsView, appSettings: appSettings)
                            }

                            Spacer()

                            Group {
                                if #available(iOS 26, *) {
                                    // Placeholder for plus button - will be in overlay
                                    Color.clear
                                        .frame(width: 72, height: 72)
                                } else {
                                    Menu {
                                        Button(action: {
                                            handleLogMultipleDrinksAction()
                                            print("log drinks view is set to \(showLogDrinksView)")
                                        }) {
                                            Label("More Options...", systemImage: "calendar.badge.plus")
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
                                            .background(
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [Color.gradientButtonPrimaryLeading, Color.gradientButtonPrimaryTrailing]),
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )
                                                    )
                                            )
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
//                                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 6)
//                                    .shadow(color: .fillPrimary.opacity(0.15), radius: 20, x: 0, y: 6)
//                                    .scaleEffect(isPressed ? 0.85 : 1)
//                                    .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: isPressed)
                                }
                            }

                            Spacer()

                            // History button
                            Group {
                                if #available(iOS 26, *) {
                                    Image(systemName: "list.bullet")
                                        .font(.system(size: 18, weight: .semibold))
                                        .opacity(isShowingMenu ? 0.2 : 1.0)
                                        .animation(.smooth(duration: 0.3), value: isShowingMenu)
                                        .frame(width: 44, height: 44)
                                        .glassEffect(.regular.tint(Color.fillTertiary).interactive())
                                        .onTapGesture {
                                            if !isShowingMenu {
                                                showHistoryView = true
                                            }
                                        }
                                } else {
                                    Button("History", systemImage: "list.bullet") {
                                        showHistoryView = true
                                    }
                                    .labelStyle(.iconOnly)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.textPrimary)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .background(
                                        Circle()
                                            .fill(colorScheme == .dark ? Color.fillTertiary.opacity(0.8) : Color.fillTertiary)
                                    )
                                    .clipShape(Circle())
                                    .buttonBorderShape(.circle)
                                }
                            }
                            .sheet(isPresented: $showHistoryView) {
                                HistoryView()
                            }

                            Spacer()
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom < 20 ? 20 : 0)
                    }

                    // iOS 26+ Menu Overlay
                    if #available(iOS 26, *) {
                        ZStack {
                            // Scrim background
                            if isShowingMenu {
                                Color.black.opacity(0.001)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        isShowingMenu = false
                                    }
                                    .transition(.opacity)
                            }

                            GlassEffectContainer {
                                VStack {
                                    Spacer()

                                    if isShowingMenu {
                                        Group {
                                            HStack(spacing: 8) {
                                                Image(systemName: "plus.circle")
                                                    .font(.body)
                                                    .foregroundStyle(.textPrimary)
                                                Text("Log a drink")
                                                    .font(.body)
                                                    .foregroundStyle(.textPrimary)
                                            }
                                            .frame(height: 44)
                                            .padding(.horizontal, 16)
                                            .onTapGesture {
                                                checkHealthKitAuthorization()
                                                logDrink()
                                                isShowingMenu = false
                                            }
                                            HStack(spacing: 8) {
                                                Image(systemName: "calendar.badge.plus")
                                                    .font(.body)
                                                    .foregroundStyle(.textPrimary)
                                                Text("More options...")
                                                    .font(.body)
                                                    .foregroundStyle(.textPrimary)
                                            }
                                            .frame(height: 44)
                                            .padding(.horizontal, 16)
                                            .onTapGesture {
                                                isShowingMenu = false
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                                    handleLogMultipleDrinksAction()
                                                }
                                            }
                                        }
                                        .glassEffect(.regular.interactive())
                                    }

                                    Button(action: {
                                        isShowingMenu.toggle()
                                    }) {
                                        Image(systemName: "plus")
                                            .font((.system(size: 28)))
                                            .foregroundStyle(isShowingMenu ? .textPrimary : .white)
                                            .rotationEffect(isShowingMenu ? .degrees(45) : .zero)
                                            .frame(width: 72, height: 72)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .glassEffect(isShowingMenu ? .regular.interactive() : .regular.tint(Color.fillPrimary).interactive())
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
                            }
                            .animation(.smooth(duration: 0.3), value: isShowingMenu)
                        }
                    }
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gradientBackgroundPrimaryLeading, Color.gradientBackgroundPrimaryTrailing]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .onAppear {
                updateTotalDrinks()
                checkHealthKitAuthorization()
            }
            .onChange(of: triggerHapticFeedback) { _, _ in
                generateHapticFeedback()
            }
            .sheet(isPresented: $showWelcomeView) {
                WelcomeView(isPresented: $showWelcomeView)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showHealthAccessView) {
                HealthAccessView(healthKitManager: healthKitManager, isPresented: $showHealthAccessView)
                    .interactiveDismissDisabled()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Health Access Denied"),
                    message: Text("Please enable HealthKit access in Settings."),
                    primaryButton: .default(Text("Open Settings"), action: {
                        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }),
                    secondaryButton: .cancel(Text("Cancel"))
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
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                performAction()
            }
        }
    }

    func performAction() {
        guard let action = qaService.action else { return }

        switch action {
        case .logDrink:
            checkHealthKitAuthorization()
            logDrink()
            print("Log drink quick action")
        case .logMultipleDrinks:
            checkHealthKitAuthorization()
            showLogDrinksView = true
            print("Log multiple drinks quick action")
        }

        qaService.action = nil
    }
}

#Preview {
    ContentView()
}
