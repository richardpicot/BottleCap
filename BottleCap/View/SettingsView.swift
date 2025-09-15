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
                    Picker(selection: $appSettings.weekStartDay) {
                        ForEach(Weekday.allCases) { weekday in
                            Text(weekday.displayName).tag(weekday)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Start Week On")
                        }
                    }

                    Picker(selection: $appSettings.drinkLimit) {
                        ForEach(1 ..< 26) { limit in
                            Text("\(limit)")
                                .tag(Double(limit))
                        }
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                            Text("Weekly Drink Limit")
                        }
                    }
                    .pickerStyle(.automatic)

                } footer: {
                    Text("It's advised not to drink more than 14 units a week on a regular basis. That's around 6 medium glasses of wine, or 6 pints of 4% beer. [More guidance on alcohol units...](https://www.nhs.uk/live-well/alcohol-advice/calculating-alcohol-units/)")
                }

                Section {
                    Button {
                        openAppStoreReview()
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Leave a Review")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .foregroundStyle(.tertiary)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.primary)

                    Button {
                        sendEmail()
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Get in Touch")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .foregroundStyle(.tertiary)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                Section {
                    NavigationLink(destination: TermsOfUseView()) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle.portrait.fill")
                            Text("Terms of Use")
                        }
                    }
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack {
                            Image(systemName: "shield.lefthalf.filled")
                            Text("Privacy Policy")
                        }
                    }
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                            Text("About")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                        }
                    } else {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Done").bold()
                        }
                    }
                }
            }
        }
    }

    func sendEmail() {
        // Check if the device can send emails
        if let url = URL(string: "mailto:hello@richardp.co") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

    func openAppStoreReview() {
        let appId = "6473561114"
        let appStoreReviewUrl = "https://apps.apple.com/app/id\(appId)?action=write-review"

        guard let url = URL(string: appStoreReviewUrl) else {
            fatalError("Expected a valid URL")
        }

        UIApplication.shared.open(url)
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true), appSettings: AppSettings.preview)
    }
}
