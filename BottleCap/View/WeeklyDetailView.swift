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
    let onDrinksUpdated: (() -> Void)?

    @Environment(\.editMode) private var editMode
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var localDailyTotals: [DailyDrinkTotal]

    init(weekStart: Date, dailyTotals: [DailyDrinkTotal], onDrinksUpdated: (() -> Void)? = nil) {
        self.weekStart = weekStart
        self.onDrinksUpdated = onDrinksUpdated
        _localDailyTotals = State(initialValue: dailyTotals)
    }

    var body: some View {
        List {
            ForEach(daysInWeek, id: \.self) { date in
                if let daily = localDailyTotals.first(where: { $0.date == date.startOfDay }) {
                    drinkRow(date: date, count: daily.totalDrinks)
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
                    if localDailyTotals.contains(where: { $0.date == date.startOfDay }) {
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
                    .disabled(localDailyTotals.isEmpty)
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
        Task {
            do {
                try await healthKitManager.deleteAlcoholDataForDate(date)
                localDailyTotals.removeAll { $0.date == date.startOfDay }
                onDrinksUpdated?()
            } catch {
                print("Failed to delete drinks: \(error.localizedDescription)")
            }
        }
    }
}
