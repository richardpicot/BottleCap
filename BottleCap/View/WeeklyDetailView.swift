//
//  WeeklyDetailView.swift
//  Bottle Cap
//
//  Created by Richard Picot on 03/10/2024.
//

import Foundation
import SwiftUI

struct WeeklyDetailView: View {
    let weekStart: Date
    let drinks: [Date: Double]
    let appSettings: AppSettings
    
    var body: some View {
        List {
            ForEach(daysInWeek, id: \.self) { date in
                if let count = drinks[date.startOfDay] {
                    drinkRow(date: date, count: count)
                }
            }
        }
        .navigationTitle(weekTitle)
    }
    
    private var weekTitle: String {
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return "\(dateFormatter.string(from: weekStart)) - \(dateFormatter.string(from: endOfWeek))"
    }
    
    private var daysInWeek: [Date] {
        (0...6).compactMap { offset in
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
}
