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
    
    @State private var showTitle = false
    @State private var showBody = false
    @State private var showButton = false
    
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .center, spacing: 16) {
                    Text("Allow access to Health")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .opacity(showTitle ? 1 : 0)
                    
                    Text("Bottle Cap securely syncs drinks with Health. It means you're always in control of your data and can delete it any time.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .opacity(showBody ? 1 : 0.2)
                        .offset(y: showBody ? 0 : 8)
                    
                    Spacer()
                    
                    Image("HealthIllustration")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                }
                .padding(32)
                
                
                VStack {
                    Spacer()
                    Button {
                        healthKitManager.requestHealthKitPermission { success, error in
                            if success {
                                // Permissions granted, dismiss the WelcomeView
                                isPresented = false
                            } else {
                                // Permissions denied or an error occurred
                                if let error = error {
                                    print("Failed to get HealthKit permission: \(error.localizedDescription)")
                                }
                                isPresented = false  // Optionally handle denied permissions
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
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 6)
                    .shadow(color: .accentPrimary.opacity(0.15), radius: 20, x: 0, y: 6)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .opacity(showButton ? 1 : 0.2)
                    .offset(y: showBody ? 0 : 8)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .background(.thickMaterial)
                    .ignoresSafeArea()
                }
                
            }
            .onAppear {
                startAnimations()
            }
        }
        
    }
    
    
    private func startAnimations() {
        // Reset states
        showTitle = false
        showBody = false
        showButton = false
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            withAnimation(Animation.easeOut(duration: 1.6)) {
                showTitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            withAnimation(Animation.easeOut(duration: 1.3)) {
                showBody = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            withAnimation(Animation.easeOut(duration: 1.3)) {
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
