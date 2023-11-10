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
    
    var body: some View {
        NavigationView {
            List(allDrinks.keys.sorted(by: >), id: \.self) { date in
                HStack {
                    Text("\(date, style: .date)")
                    Spacer()
                    Text("\(allDrinks[date]!, specifier: "%.0f")")
                        .foregroundStyle(.secondary)
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
        .onAppear {
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

    }
}


struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
