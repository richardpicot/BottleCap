//
//  HistoryView.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 23/10/2023.
//

import HealthKit
import SwiftUI

struct HistoryView: View {
    @State private var allDrinks: [Date: Double] = [:]
    @State private var allDrinkSamples: [Date: [HKQuantitySample]] = [:]
    @Environment(\.editMode) private var editMode
    @ObservedObject var healthKitManager = HealthKitManager()
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appSettings = AppSettings.shared

    var body: some View {
        NavigationView {
            Group {
                if allDrinks.isEmpty {
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
                                ForEach(drinksThisWeek, id: \.0) { date, count in
                                    drinkRow(date: date, count: count)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            if editMode?.wrappedValue == .inactive {
                                                Button(role: .destructive) {
                                                    deleteDrinksForDate(date)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        let date = drinksThisWeek[index].0
                                        deleteDrinksForDate(date)
                                    }
                                }
                            } header: {
                                Text("This week")
                            }
                        }

                        if !drinksPreviousWeeks.isEmpty {
                            Section {
                                ForEach(drinksPreviousWeeks, id: \.0) { weekStart, count in
                                    Group {
                                        if editMode?.wrappedValue == .active {
                                            drinkRow(date: weekStart, count: count, isWeekly: true)
                                        } else {
                                            NavigationLink(destination: WeeklyDetailView(weekStart: weekStart, drinks: allDrinks, appSettings: appSettings, onDrinksUpdated: updateDrinks)) {
                                                drinkRow(date: weekStart, count: count, isWeekly: true)
                                            }
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        if editMode?.wrappedValue == .inactive {
                                            Button(role: .destructive) {
                                                deleteDrinksForWeek(weekStart)
                                            } label: {
                                                Label("Delete Week", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        let weekStart = drinksPreviousWeeks[index].0
                                        deleteDrinksForWeek(weekStart)
                                    }
                                }
                            } header: {
                                Text("Previous weeks")
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
                        .disabled(allDrinks.isEmpty)
                }
            }
        }
        .onAppear {
            updateDrinks()
        }
    }

    private var drinksThisWeek: [(Date, Double)] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(toNearestOrLastWeekday: appSettings.weekStartDay, matching: Date()) else {
            return []
        }
        // Include drinks from the start of the week
        return allDrinks.filter { $0.key >= startOfWeek.startOfDay }.sorted { $0.key > $1.key }
    }

    private var drinksPreviousWeeks: [(Date, Double)] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(toNearestOrLastWeekday: appSettings.weekStartDay, matching: Date()) else {
            return []
        }
        // Exclude drinks from the start of the week and later
        let previousWeeksDrinks = allDrinks.filter { $0.key < startOfWeek.startOfDay }
        return groupDrinksByWeek(drinks: previousWeeksDrinks)
    }

    private func groupDrinksByWeek(drinks: [Date: Double]) -> [(Date, Double)] {
        let calendar = Calendar.current
        var weeklyDrinks: [Date: Double] = [:]

        for (date, count) in drinks {
            guard let weekStart = calendar.date(toNearestOrLastWeekday: appSettings.weekStartDay, matching: date) else {
                continue
            }
            weeklyDrinks[weekStart, default: 0] += count
        }

        return weeklyDrinks.sorted { $0.key > $1.key }
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
        healthKitManager.readAllAlcoholEntries { drinks in
            var drinksByDate: [Date: Double] = [:]
            var samplesByDate: [Date: [HKQuantitySample]] = [:]

            for drink in drinks {
                let date = drink.endDate.startOfDay
                let count = drink.quantity.doubleValue(for: HKUnit.count())

                drinksByDate[date, default: 0] += count
                samplesByDate[date, default: []].append(drink)
            }

            self.allDrinks = drinksByDate
            self.allDrinkSamples = samplesByDate
        }
    }

    private func deleteDrinksForDate(_ date: Date) {
        healthKitManager.deleteAlcoholDataForDate(date) { success, error in
            if success {
                // Update the local data
                allDrinks.removeValue(forKey: date)
                allDrinkSamples.removeValue(forKey: date)
            } else {
                print("Failed to delete drinks: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    private func deleteDrinksForWeek(_ weekStart: Date) {
        let calendar = Calendar.current
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: weekStart)!

        // Get all dates in this week that have drinks
        let datesInWeek = allDrinks.keys.filter { date in
            date >= weekStart.startOfDay && date <= endOfWeek.startOfDay
        }

        // Delete drinks for each date in the week
        let group = DispatchGroup()
        var allSuccessful = true

        for date in datesInWeek {
            group.enter()
            healthKitManager.deleteAlcoholDataForDate(date) { success, error in
                if !success {
                    allSuccessful = false
                    print("Failed to delete drinks for date \(date): \(String(describing: error?.localizedDescription))")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if allSuccessful {
                // Update the local data
                for date in datesInWeek {
                    allDrinks.removeValue(forKey: date)
                    allDrinkSamples.removeValue(forKey: date)
                }
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
