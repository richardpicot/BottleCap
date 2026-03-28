//
//  HealthAccessView.swift
//  Bottle Cap
//
//  Created by Richard Picot on 24/10/2023.
//

import HealthKit
import SwiftUI

struct HealthAccessView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
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
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .white, location: 0),
                            .init(color: .white, location: 0.5),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                )
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
                        requestPermission()
                    } label: {
                        ZStack {
                            Text("Connect to Health")
                                .fontWeight(.semibold)
                                .opacity(isRequestingPermission ? 0 : 1)

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
                        requestPermission()
                    } label: {
                        ZStack {
                            Text("Connect to Health")
                                .fontWeight(.semibold)
                                .opacity(isRequestingPermission ? 0 : 1)

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
        }
    }

    private func requestPermission() {
        isRequestingPermission = true
        Task {
            do {
                try await healthKitManager.requestHealthKitPermission()
            } catch {
                print("Failed to get HealthKit permission: \(error.localizedDescription)")
            }
            isRequestingPermission = false
            isPresented = false
        }
    }
}

struct HealthAccessView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HealthAccessView(isPresented: .constant(true))
                .environmentObject(HealthKitManager())
        }
    }
}
