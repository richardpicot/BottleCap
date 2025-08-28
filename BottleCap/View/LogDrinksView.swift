//
//  LogDrinksView.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 23/10/2023.
//

import HealthKit
import SwiftUI

struct LogDrinksView: View {
    @Binding var isPresented: Bool
    var logDrinkClosure: (Double, Date) -> Void
    let totalDrinks: Double
    let drinkLimit: Double
    @State private var numberOfDrinksString: String = ""
    @State private var lastValidNumberOfDrinksString: String = ""
    @State private var date: Date = .init()
    @FocusState private var drinksFocus: Bool

    @ObservedObject var healthKitManager = HealthKitManager()

    private func triggerHapticFeedback(totalDrinks: Double, drinkLimit: Double) {
        let feedbackGenerator = UINotificationFeedbackGenerator()

        if totalDrinks >= drinkLimit {
            feedbackGenerator.notificationOccurred(.error)
            print("Error haptic played")
        } else {
            feedbackGenerator.notificationOccurred(.success)
            print("Success haptic played")
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Drinks")
                            .bold()
                        Spacer()
                        TextField("Required", text: $numberOfDrinksString)
                            .onChange(of: numberOfDrinksString) { newValue, _ in
                                let decimalCount = newValue.filter { $0 == "." }.count
                                if decimalCount > 1 {
                                    numberOfDrinksString = lastValidNumberOfDrinksString
                                } else {
                                    // Update the last valid value
                                    lastValidNumberOfDrinksString = newValue
                                }
                            }
                            .focused($drinksFocus)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }

                Section {
                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.all, -8)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if #available(iOS 26.0, *) {
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
                        }
                    } else {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button(action: {
                            if let numberOfDrinks = Double(numberOfDrinksString) {
                                triggerHapticFeedback(totalDrinks: totalDrinks, drinkLimit: drinkLimit)
                                logDrinkClosure(numberOfDrinks, date)
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "checkmark")
                        }
                        .disabled(numberOfDrinksString.isEmpty || Double(numberOfDrinksString) ?? 21 > 20)
                    } else {
                        Button("Save") {
                            if let numberOfDrinks = Double(numberOfDrinksString) {
                                triggerHapticFeedback(totalDrinks: totalDrinks, drinkLimit: drinkLimit)
                                logDrinkClosure(numberOfDrinks, date)
                                isPresented = false
                            }
                        }
                        .disabled(numberOfDrinksString.isEmpty || Double(numberOfDrinksString) ?? 21 > 20)
                        .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("Log Drinks")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            drinksFocus = true
        }
    }
}

struct LogDrinksView_Previews: PreviewProvider {
    static var previews: some View {
        LogDrinksView(
            isPresented: .constant(true),
            logDrinkClosure: { _, _ in },
            totalDrinks: 5, // Example value
            drinkLimit: 10 // Example value
        )
    }
}
