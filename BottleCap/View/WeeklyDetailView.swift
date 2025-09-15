//
//  WeeklyDetailView.swift
//  Bottle Cap
//
//  Created by Richard Picot on 03/10/2024.
//

import Foundation
import HealthKit
import SwiftUI

struct WeeklyDetailView: View {
    let weekStart: Date
    let drinks: [Date: Double]
    let appSettings: AppSettings
    let onDrinksUpdated: (() -> Void)?

    @Environment(\.editMode) private var editMode
    @ObservedObject private var healthKitManager = HealthKitManager()
    @State private var localDrinks: [Date: Double]

    init(weekStart: Date, drinks: [Date: Double], appSettings: AppSettings, onDrinksUpdated: (() -> Void)? = nil) {
        self.weekStart = weekStart
        self.drinks = drinks
        self.appSettings = appSettings
        self.onDrinksUpdated = onDrinksUpdated
        _localDrinks = State(initialValue: drinks)
    }

    var body: some View {
        List {
            ForEach(daysInWeek, id: \.self) { date in
                if let count = localDrinks[date.startOfDay] {
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
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let date = daysInWeek[index]
                    if localDrinks[date.startOfDay] != nil {
                        deleteDrinksForDate(date)
                    }
                }
            }
        }
        .navigationTitle(weekTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .fontWeight(.medium)
                    .disabled(localDrinks.isEmpty)
            }
        }
        .environment(\.editMode, editMode)
    }

    private var weekTitle: String {
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return "\(dateFormatter.string(from: weekStart)) - \(dateFormatter.string(from: endOfWeek))"
    }

    private var daysInWeek: [Date] {
        (0 ... 6).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: weekStart)
        }
    }

    private func drinkRow(date: Date, count: Double) -> some View {
        HStack {
            Text(date, format: .dateTime.weekday().day().month().year())
            Spacer()
            let formattedDrinkCount = NumberFormatterUtility.formatRounded(count)
            Text("\(formattedDrinkCount) \(count == 1 ? "drink" : "drinks")")
                .foregroundStyle(.secondary)
        }
    }

    private func deleteDrinksForDate(_ date: Date) {
        healthKitManager.deleteAlcoholDataForDate(date) { success, error in
            if success {
                // Update the local data
                localDrinks.removeValue(forKey: date.startOfDay)
                // Notify parent view to refresh
                onDrinksUpdated?()
            } else {
                print("Failed to delete drinks: \(String(describing: error?.localizedDescription))")
            }
        }
    }
}
