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
                    Picker("Start Week On", selection: $appSettings.weekStartDay) {
                        ForEach(Weekday.allCases) { weekday in
                            Text(weekday.displayName).tag(weekday)
                        }
                    }
                    
                    Picker("Weekly Limit", selection: $appSettings.drinkLimit) {
                        ForEach(1..<51) { limit in
                            HStack(spacing: 4) {
                                Text("\(limit)")
                                Text(limit == 1 ? "Drink" : "Drinks")
                            }
                            .tag(Double(limit))
                        }
                    }
                    .pickerStyle(.navigationLink)

                    
                } footer: {
                    Text("It's advised not to drink more than 14 units a week on a regular basis. That's around 6 medium glasses of wine, or 6 pints of 4% beer. [Learn more...](https://www.nhs.uk/live-well/alcohol-advice/calculating-alcohol-units/)")
                }
                
                Section {
                    NavigationLink("Privacy Policy", destination: PrivacyPolicyView())
                    NavigationLink("About", destination: AboutView())
                }
                
                Section {
                    Button("Leave a Review") {
                        // add review code
                    }
                    Button("Get in Touch") {
                        // add email
                    }
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
