//
//  HealthAccessView.swift
//  Bottle Cap
//
//  Created by Richard Picot on 24/10/2023.
//

import HealthKit
import SwiftUI

struct HealthAccessView: View {
    var healthKitManager: HealthKitManager
    @Binding var isPresented: Bool // Binding variable to control the presentation of HealthAccessView
    @State private var isRequestingPermission = false

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Allow access to Health")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text("Bottle Cap securely syncs drinks with Health. It means you're always in control of your data and can delete it any time.")
                .font(.title3)
                .multilineTextAlignment(.center)

            Spacer()

            Image("HealthIllustration")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
        }
        .padding(.horizontal, 24)
        // Same inline bar metrics, visually empty principal item so we keep a consistent bar and get a back button.
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Color.clear
                    .frame(width: 1, height: 1)
                    .accessibilityHidden(true)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Group {
                if #available(iOS 26, *) {
                    Button {
                        isRequestingPermission = true // Show spinner

                        healthKitManager.requestHealthKitPermission { success, error in
                            DispatchQueue.main.async {
                                isRequestingPermission = false // Hide spinner
                                if success {
                                    self.isPresented = false
                                } else {
                                    if let error = error {
                                        print("Failed to get HealthKit permission: \(error.localizedDescription)")
                                    }
                                    self.isPresented = false
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            Text("Connect to Health")
                                .fontWeight(.semibold)
                                .opacity(isRequestingPermission ? 0 : 1) // Hide text when showing spinner

                            if isRequestingPermission {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .controlSize(.regular)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .cornerRadius(100)
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 6)
                    .shadow(color: .fillPrimary.opacity(0.15), radius: 20, x: 0, y: 6)
                } else {
                    Button {
                        isRequestingPermission = true // Show spinner

                        healthKitManager.requestHealthKitPermission { success, error in
                            DispatchQueue.main.async {
                                isRequestingPermission = false // Hide spinner
                                if success {
                                    self.isPresented = false
                                } else {
                                    if let error = error {
                                        print("Failed to get HealthKit permission: \(error.localizedDescription)")
                                    }
                                    self.isPresented = false
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            Text("Connect to Health")
                                .fontWeight(.semibold)
                                .opacity(isRequestingPermission ? 0 : 1) // Hide text when showing spinner

                            if isRequestingPermission {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .controlSize(.regular)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .cornerRadius(100)
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 6)
                    .shadow(color: .fillPrimary.opacity(0.15), radius: 20, x: 0, y: 6)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(.thinMaterial)
        }
    }
}

struct HealthAccessView_Previews: PreviewProvider {
    static var previews: some View {
        // Dummy HealthKitManager
        let healthKitManager = HealthKitManager()

        // Use a constant binding for isPresented
        NavigationStack {
            HealthAccessView(healthKitManager: healthKitManager, isPresented: .constant(true))
        }
    }
}
