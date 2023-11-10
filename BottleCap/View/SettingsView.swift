//
//  SettingsView.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 23/10/2023.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool
    @ObservedObject var appSettings: AppSettings
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Start week on", selection: $appSettings.weekStartDay) {
                        ForEach(Weekday.allCases) { weekday in
                            Text(weekday.displayName).tag(weekday)
                        }
                    }
                    
                    Picker("Weekly drink limit", selection: $appSettings.drinkLimit) {
                        ForEach(0..<51) { limit in               Text("\(limit)").tag(Double(limit))
                        }
                    }
                    
                } footer: {
                    Text("It's recommended to drink no more than 14 units of alcohol a week. That's around 6 medium glasses of wine, or 6 pints of 4% beer.")
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Done").bold()
            })
        }
    }
}



struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true), appSettings: AppSettings.preview)
    }
}
