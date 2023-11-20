//
//  WelcomeView.swift
//  Bottle Cap
//
//  Created by Richard Picot on 24/10/2023.
//

import SwiftUI
import HealthKit

struct WelcomeView: View {
    
    var healthKitManager: HealthKitManager
    @Binding var isPresented: Bool // Binding variable to control the presentation of WelcomeView
    
    @State private var showRectangle = false
    @State private var showTitle = false
    @State private var showBody = false
    @State private var showButton = false
    @State private var showSettingsAlert = false

    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(Color.backgroundSecondary)
                        .frame(width: 128, height: 128)
                        .scaleEffect(showRectangle ? 1 : 0.2)
                        .opacity(showRectangle ? 1 : 0)
                    
                    VStack {
                        Text("Allow access to Health")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                            .padding()
                            .opacity(showTitle ? 1 : 0)
                            .offset(y: showTitle ? 0 : 10)
                        
                        Text("Bottle Cap logs your drinks to Health. It means you're always in control of your data and you can delete it at any time.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .opacity(showBody ? 1 : 0)
                            .offset(y: showBody ? 0 : 10)
                    }
                    .foregroundColor(Color.inkPrimary)
                    .padding()
                    
                    Spacer()
                    
                    // Button to request HealthKit permissions
                    Button {
                        healthKitManager.requestHealthKitPermission { success, error in
                            if success {
                                // Navigate to ContentView when the user grants access
                                isPresented = true
                            } else {
                                print(error?.localizedDescription ?? "Failed to get HealthKit permission.")
                            }
                        }
                    } label: {
                        Text("Connect to Health")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .cornerRadius(100)
                    .padding()
                    .opacity(showButton ? 1 : 0)
                    .scaleEffect(showButton ? 1 : 0.9)
                }
                .onAppear {
                    startAnimations()
                }
            }
        }
        .alert("Permission Denied", isPresented: $showSettingsAlert) {
            Button("Go to Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    
    private func startAnimations() {
        // Reset states
        showRectangle = false
        showTitle = false
        showBody = false
        showButton = false
        
        withAnimation(Animation.spring(duration: 1.5)) {
            showRectangle = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(Animation.easeInOut(duration: 0.3)) {
                showTitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(Animation.easeInOut(duration: 0.3)) {
                showBody = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            withAnimation(Animation.easeInOut(duration: 0.3)) {
                showButton = true
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        // Dummy HealthKitManager
        let healthKitManager = HealthKitManager()
        
        // Use a constant binding for isPresented
        WelcomeView(healthKitManager: healthKitManager, isPresented: .constant(true))
    }
}
