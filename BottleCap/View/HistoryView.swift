//
//  HistoryView.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 23/10/2023.
//

import SwiftUI
import HealthKit

struct HistoryView: View {
    @State private var allDrinks: [Date: Double] = [:]
    @ObservedObject var healthKitManager = HealthKitManager()
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appSettings = AppSettings.shared
    
    var body: some View {
        NavigationView {
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
                    Section {
                        ForEach(drinksThisWeek, id: \.0) { date, count in
                            drinkRow(date: date, count: count)
                        }
                    } header: {
                        Text("This week")
                    } footer: {
                        if drinksPreviousWeeks.isEmpty {
                            editInHealthButton
                        }
                    }
                    
                    if !drinksPreviousWeeks.isEmpty {
                        Section {
                            ForEach(drinksPreviousWeeks, id: \.0) { weekStart, count in
                                drinkRow(date: weekStart, count: count, isWeekly: true)
                            }
                        } header: {
                            Text("Previous weeks")
                        } footer: {
                            editInHealthButton
                        }
                    }
                }
                .navigationBarTitle("History", displayMode: .inline)
                .toolbar {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done").bold()
                    }
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

    private func drinkRow(date: Date, count: Double, isWeekly: Bool = false) -> some View {
        HStack {
            Text(date, format: .dateTime.weekday().day().month().year())
            Spacer()
            let formattedDrinkCount = NumberFormatterUtility.formatRounded(count)
            Text("\(formattedDrinkCount) \(count == 1 ? "drink" : "drinks")")
                .foregroundStyle(.secondary)
        }
    }
    
    private func updateDrinks() {
        healthKitManager.readAllAlcoholEntries { drinks in
            var drinksByDate: [Date: Double] = [:]
            
            for drink in drinks {
                let date = drink.endDate.startOfDay
                let count = drink.quantity.doubleValue(for: HKUnit.count())
                
                drinksByDate[date, default: 0] += count
            }
            
            self.allDrinks = drinksByDate
        }
    }
    
    private var editInHealthButton: some View {
        HStack(spacing: 2) {
            Text("[Edit in Health](x-apple-health://)")
            Image(systemName: "arrow.up.forward")
                .foregroundColor(.accentColor)
                .onTapGesture {
                    if let url = URL(string: "x-apple-health://") {
                        UIApplication.shared.open(url)
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
