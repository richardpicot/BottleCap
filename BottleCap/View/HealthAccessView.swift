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
//
//    @State private var showTitle = false
//    @State private var showBody = false
//    @State private var showButton = false
    @State private var isRequestingPermission = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .center, spacing: 16) {
                    Text("Allow access to Health")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
//                        .opacity(showTitle ? 1 : 0)

                    Text("Bottle Cap securely syncs drinks with Health. It means you're always in control of your data and can delete it any time.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
//                        .opacity(showBody ? 1 : 0.2)
//                        .scaleEffect(showBody ? 1 : 0.9)

                    Spacer()

                    Image("HealthIllustration")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                }
                .padding(.horizontal, 24)

                VStack {
                    Spacer()
                    if #available(iOS 26, *) {
                        Button {
                            isRequestingPermission = true // Show spinner

                            healthKitManager.requestHealthKitPermission { success, error in
                                DispatchQueue.main.async {
                                    isRequestingPermission = false // Hide spinner
                                    if success {
                                        // Permissions granted, dismiss the HealthAccessView
                                        self.isPresented = false
                                    } else {
                                        // Permissions denied or an error occurred
                                        if let error = error {
                                            print("Failed to get HealthKit permission: \(error.localizedDescription)")
                                        }
                                        self.isPresented = false // Optionally handle denied permissions
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
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                    } else {
                        Button {
                            isRequestingPermission = true // Show spinner

                            healthKitManager.requestHealthKitPermission { success, error in
                                DispatchQueue.main.async {
                                    isRequestingPermission = false // Hide spinner
                                    if success {
                                        // Permissions granted, dismiss the HealthAccessView
                                        self.isPresented = false
                                    } else {
                                        // Permissions denied or an error occurred
                                        if let error = error {
                                            print("Failed to get HealthKit permission: \(error.localizedDescription)")
                                        }
                                        self.isPresented = false // Optionally handle denied permissions
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
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                    }
                }
            }
        }
    }
}

struct HealthAccessView_Previews: PreviewProvider {
    static var previews: some View {
        // Dummy HealthKitManager
        let healthKitManager = HealthKitManager()

        // Use a constant binding for isPresented
        HealthAccessView(healthKitManager: healthKitManager, isPresented: .constant(true))
    }
}
