//
//  TermsOfUseView.swift
//  Bottle Cap
//
//  Created by Richard Picot on 11/11/2023.
//

import SwiftUI

struct TermsOfUseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                    Text("By accessing and using the Bottle Cap application (\"App\"), you agree to be bound by these Terms of Use (\"Terms\"). If you do not agree to these Terms, you must not use the App.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("2. Description of Service")
                        .font(.headline)
                        .bold()
                    Text("The App provides a platform for users to log and track their casual alcohol consumption. The App is intended for personal use only and is not a medical or health service.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("3. User Eligibility")
                        .font(.headline)
                        .bold()
                    Text("The App is intended for users who are of legal drinking age in their respective country. By using the App, you represent and warrant that you meet this age requirement.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("4. User Responsibilities")
                        .font(.headline)
                        .bold()
                    Text("4.1 Legal Compliance: You agree to use the App in compliance with all applicable laws and regulations.\n4.2 Responsible Use: The App is a tool for logging alcohol consumption and should not be used to encourage excessive or irresponsible drinking.\n4.3 Accuracy of Information: You are responsible for the accuracy of the data you enter into the App.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("5. Intellectual Property")
                        .font(.headline)
                        .bold()
                    Text("All content and functionality on the App, including text, graphics, logos, and software, are the exclusive property of Richard Picot and are protected by intellectual property laws.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("6. Privacy Policy")
                        .font(.headline)
                        .bold()
                    Text("Your use of the App is also governed by our [Privacy Policy](https://richardp.co/published/bottle-cap-privacy-policy/), which outlines how we handle user data.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("7. Disclaimer of Warranties")
                        .font(.headline)
                        .bold()
                    Text("The App is provided \"as is,\" without warranty of any kind. We do not guarantee the accuracy or completeness of any information on the App.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("8. Limitation of Liability")
                        .font(.headline)
                        .bold()
                    Text("Richard Picot shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the App.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("9. Changes to Terms")
                        .font(.headline)
                        .bold()
                    Text("We reserve the right to modify these Terms at any time. Your continued use of the App following any changes indicates your acceptance of the new Terms.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("10. Governing Law")
                        .font(.headline)
                        .bold()
                    Text("These Terms shall be governed by the laws of the United Kingdom, without regard to its conflict of law provisions.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("11. Contact Information")
                        .font(.headline)
                        .bold()
                    Text("For any questions or concerns regarding these Terms, please contact me at hello@richardp.co")
                }
                
            }
            .padding()
        }
        .navigationBarTitle("Terms of Use", displayMode: .inline)
    }
}

struct TermsOfUseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TermsOfUseView()
        }
    }
}
