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
            if allDrinks.isEmpty {
                VStack(spacing: 16) {
                    Text("🍺")
                        .font(.system(size: 48))
                        .grayscale(1)
                        .opacity(0.6)
                    
                    VStack {
                        Text("No Drinks Logged")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Text("Drinks you log will appear here.\nTap the plus to get started.")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .multilineTextAlignment(.center)
            } else {
                List {
                    Section(footer:
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
                    ) {
                        ForEach(allDrinks.keys.sorted(by: >), id: \.self) { date in
                            HStack {
                                Text("\(date, format: .dateTime.weekday().day().month().year())")
                                Spacer()
                                let drinkCount = allDrinks[date]!
                                Text("\(drinkCount, specifier: "%.0f") \(drinkCount == 1 ? "drink" : "drinks")")
                                    .foregroundStyle(.secondary)
                            }
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
