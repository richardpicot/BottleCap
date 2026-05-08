//
//  HistoryView.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 23/10/2023.
//

import HealthKit
import SwiftUI

struct HistoryView: View {
    @State private var dailyTotals: [DailyDrinkTotal] = []
    @State private var allDrinkSamples: [Date: [HKQuantitySample]] = [:]
    @State private var isLoading = true
    @Environment(\.editMode) private var editMode
    @EnvironmentObject var healthKitManager: HealthKitManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var appSettings: AppSettings

    private var drinksThisWeek: [DailyDrinkTotal] {
        DrinkDataService.currentWeekDailyTotals(from: dailyTotals, weekStartDay: appSettings.weekStartDay)
    }

    private var drinksByMonth: [MonthlyDrinkGroup] {
        DrinkDataService.previousWeeksMonthlyGroups(from: dailyTotals, weekStartDay: appSettings.weekStartDay)
    }

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading history...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if dailyTotals.isEmpty {
                    VStack(spacing: 16) {
                        Text("🍺")
                            .font(.system(size: 48))
                            .grayscale(1)
                            .opacity(0.6)

                        VStack(spacing: 12) {
                            Text("No Drinks Logged")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            Text("Drinks you log will appear here.\nTap the plus to get started.")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .multilineTextAlignment(.center)
                } else {
                    List {
                        if !drinksThisWeek.isEmpty {
                            Section {
                                ForEach(drinksThisWeek) { daily in
                                    drinkRow(date: daily.date, count: daily.totalDrinks)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            if editMode?.wrappedValue == .inactive {
                                                Button(role: .destructive) {
                                                    deleteDrinksForDate(daily.date)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        let date = drinksThisWeek[index].date
                                        deleteDrinksForDate(date)
                                    }
                                }
                            } header: {
                                Text("This week")
                            }
                        }

                        ForEach(drinksByMonth) { month in
                            Section {
                                ForEach(month.weeks) { week in
                                    Group {
                                        if editMode?.wrappedValue == .active {
                                            drinkRow(date: week.weekStart, count: week.totalDrinks, isWeekly: true)
                                        } else {
                                            NavigationLink(destination: WeeklyDetailView(weekStart: week.weekStart, dailyTotals: week.dailyTotals, onDrinksUpdated: updateDrinks)) {
                                                drinkRow(date: week.weekStart, count: week.totalDrinks, isWeekly: true)
                                            }
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        if editMode?.wrappedValue == .inactive {
                                            Button(role: .destructive) {
                                                deleteDrinksForWeek(week.weekStart)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        let weekStart = month.weeks[index].weekStart
                                        deleteDrinksForWeek(weekStart)
                                    }
                                }
                            } header: {
                                Text(month.monthLabel)
                            }
                        }
                    }
                    .environment(\.editMode, editMode)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .fontWeight(.medium)
                        .disabled(dailyTotals.isEmpty || isLoading)
                }
            }
        }
        .onAppear {
            updateDrinks()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                updateDrinks()
            }
        }
    }

    private func weekTitle(for date: Date) -> String {
        let calendar = Calendar.current
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: date)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return "\(dateFormatter.string(from: date)) - \(dateFormatter.string(from: endOfWeek))"
    }

    private func drinkRow(date: Date, count: Double, isWeekly: Bool = false) -> some View {
        HStack {
            if isWeekly {
                Text(weekTitle(for: date))
            } else {
                if Calendar.current.isDateInToday(date) {
                    Text("Today")
                } else {
                    Text(date, format: .dateTime.weekday().day().month())
                }
            }
            Spacer()
            let formattedDrinkCount = NumberFormatterUtility.formatRounded(count)
            Text("\(formattedDrinkCount) \(count == 1 ? "drink" : "drinks")")
                .foregroundStyle(.secondary)
        }
    }

    private func updateDrinks() {
        Task {
            let samples = await healthKitManager.readAllAlcoholEntries()

            var samplesByDate: [Date: [HKQuantitySample]] = [:]
            for sample in samples {
                let date = sample.endDate.startOfDay
                samplesByDate[date, default: []].append(sample)
            }

            dailyTotals = DrinkDataService.dailyTotals(from: samples)
            allDrinkSamples = samplesByDate
            isLoading = false
        }
    }

    private func deleteDrinksForDate(_ date: Date) {
        Task {
            do {
                try await healthKitManager.deleteAlcoholDataForDate(date)
                dailyTotals.removeAll { $0.date == date }
                allDrinkSamples.removeValue(forKey: date)
            } catch {
                print("Failed to delete drinks: \(error.localizedDescription)")
            }
        }
    }

    private func deleteDrinksForWeek(_ weekStart: Date) {
        let calendar = Calendar.current
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: weekStart)!

        // Get all dates in this week that have drinks
        let datesInWeek = dailyTotals
            .map(\.date)
            .filter { $0 >= weekStart.startOfDay && $0 <= endOfWeek.startOfDay }

        Task {
            do {
                for date in datesInWeek {
                    try await healthKitManager.deleteAlcoholDataForDate(date)
                }
                // Update the local data
                let dateSet = Set(datesInWeek)
                dailyTotals.removeAll { dateSet.contains($0.date) }
                for date in datesInWeek {
                    allDrinkSamples.removeValue(forKey: date)
                }
            } catch {
                print("Failed to delete drinks for week: \(error.localizedDescription)")
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(HealthKitManager())
            .environmentObject(AppSettings.shared)
    }
}
