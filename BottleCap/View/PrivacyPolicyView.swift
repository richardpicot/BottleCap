//
//  PrivacyPolicyView.swift
//  Bottle Cap
//
//  Created by Richard Picot on 11/11/2023.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("TL;DR")
                        .font(.headline)
                    Text("Your data never leaves your device. Bottle Cap reads and writes health data exclusively from, and to HealthKit on your device. All your data is saved on your iCloud.")
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Health Data")
                        .font(.headline)
                        .bold()
                    Text("We use Apple's APIs to read and/or write your alcohol consumption to the Apple Health app on your device. This data is stored locally on your device. We do not have access to this data, nor do we collect any personal information.\n\nThis app cannot read from or write to Apple Health without your consent.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Changes to This Privacy Policy")
                        .font(.headline)
                        .bold()
                    Text("We may update our Privacy Policy from time to time. These changes will be effective immediately after being posted on this page. We will notify you of any changes by posting the new Privacy Policy on this page.\n\nWe will not change this agreement to allow the collection of your personal information or make other significant changes without your consent.\n\nWe encourage you to periodically review this Privacy Policy for any updates.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Disclaimers")
                        .font(.headline)
                        .bold()
                    Text("We make no guarantees as to the suitability of this app for the user, or for any of its functionality, accuracy, or usefulness, and will not be held responsible in the event that damage is incurred.\n\nWe reserve the right to change this app or to stop offering it. We will not be held responsible if the app is discontinued, changed, or otherwise made unusable and data is damaged or lost as a result, or if the device itself is damaged, or if the device incurred damage due to another app.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contact")
                        .font(.headline)
                        .bold()
                    Text("If you have any questions or concerns about this Privacy Policy, please contact me at hello@richardp.co")
                }
                
            }
            .padding()
        }
        .navigationBarTitle("Privacy Policy", displayMode: .inline)
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrivacyPolicyView()
        }
    }
}
