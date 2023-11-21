//
//  LogDrinksView.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 23/10/2023.
//

import SwiftUI
import HealthKit

struct LogDrinksView: View {
    @Binding var isPresented: Bool
    var updateTotalDrinks: () -> Void
    @State private var numberOfDrinksString: String = ""  // User input stored as a String
    @State private var date: Date = Date()
    @State private var triggerHapticFeedback = false
    @FocusState private var drinksFocus: Bool
    
    @ObservedObject var healthKitManager = HealthKitManager()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Drinks")
                            .bold()
                        Spacer()
                        TextField("Required", text: $numberOfDrinksString)
                            .focused($drinksFocus)
                            .keyboardType(.numberPad)
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
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let numberOfDrinks = Double(numberOfDrinksString) {
                            healthKitManager.addAlcoholData(numberOfDrinks: numberOfDrinks, date: date) {
                                updateTotalDrinks()
                            }
                        }
                        
                        isPresented = false
                    }
                    .disabled(numberOfDrinksString.isEmpty)
                    .fontWeight(.bold)
                }
            }
            .navigationBarTitle("Log Drinks", displayMode: .inline)
        }
        .onAppear {
            drinksFocus = true
        }
    }
}

struct LogDrinksView_Previews: PreviewProvider {
    static var previews: some View {
        LogDrinksView(isPresented: .constant(true), updateTotalDrinks: {})
    }
}

