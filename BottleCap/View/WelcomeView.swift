import SwiftUI

struct WelcomeView: View {
    
    @State private var showTitle = false
    @State private var showBody = false
    @State private var showButton = false
    @State private var showTermsOfUse = false // State to control the presentation of the TermsOfUseView
    
    @Binding var isPresented: Bool
    
    let animationDuration = 0.6
    let staggerDelay = 0.1
    
    @State private var isRequestingPermission = false
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    VStack {
                        Image("BottleCap")
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 4)
                            .shadow(color: .black.opacity(0.1), radius: 7, x: 0, y: 14)
                            .shadow(color: .black.opacity(0.05), radius: 9.5, x: 0, y: 32)
                        
                        // title
                        VStack(alignment: .center, spacing: 0.0) {
                            Text("Welcome to")
                            Text("Bottle Cap")
                                .foregroundStyle(.textAccent)
                        }
                        .font(.system(size: 40, weight: .bold))
                    }
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 8)
                    
                    // feature list
                    VStack(alignment: .leading, spacing: 16.0) {
                        // feature 1
                        HStack(alignment: .top, spacing: 16.0) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .frame(width: 40, height: 40, alignment: .center)
                                .foregroundStyle(.fillSecondary)
                            VStack(alignment: .leading) {
                                Text("Effortless drinks logging")
                                    .font(.body.bold())
                                    .foregroundStyle(.primary)
                                Text("Forget about calculating measures or alcohol strength, log based on number of drinks.")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        // feature 2
                        HStack(alignment: .top, spacing: 16.0) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 28))
                                .frame(width: 40, height: 40, alignment: .center)
                                .foregroundStyle(.fillSecondary)
                            VStack(alignment: .leading) {
                                Text("Set your weekly limit")
                                    .font(.body.bold())
                                    .foregroundStyle(.primary)
                                Text("Choose a weekly limit that feels right for you, no judgement.")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        // feature 3
                        HStack(alignment: .top, spacing: 16.0) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 28))
                                .frame(width: 40, height: 40, alignment: .center)
                                .foregroundStyle(.fillSecondary)
                            VStack(alignment: .leading) {
                                Text("See your intake at a glance")
                                    .font(.body.bold())
                                    .foregroundStyle(.primary)
                                Text("The number of drinks you’ve logged in a week are front and centre.")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .opacity(showBody ? 1 : 0.2)
                    .offset(y: showBody ? 0 : 8)
                    
                    
                    Spacer()
                    
                }
                .padding(24)
            }
            
            // Footer VStack
            VStack(spacing: 24) {
                Button(action: {
                    showTermsOfUse = true
                }) {
                    Text("Bottle Cap was designed to track and limit casual alcohol consumption, not to manage an addiction.\nBy proceeding, you confirm you are not suffering from alcohol dependency and agree to our ")
                                       .foregroundColor(.secondary)
                                       .font(.footnote)
                                       +
                                   Text("Terms of Use")
                                       .foregroundColor(.textAccent)
                                       .font(.footnote)
                                       
                    
                }
                .sheet(isPresented: $showTermsOfUse) {
                    NavigationView {
                        TermsOfUseView()
                    }
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
                }

                
                NavigationLink(destination: HealthAccessView(healthKitManager: HealthKitManager(), isPresented: $isPresented)) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .foregroundColor(.white) // Set text color
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor) // Set background color
                        .cornerRadius(100)
                        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 6)
                        .shadow(color: .fillPrimary.opacity(0.15), radius: 20, x: 0, y: 6)
                }
                .buttonStyle(.plain) // Apply plain style to hide default link style
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .opacity(showButton ? 1 : 0.2)
            .offset(y: showButton ? 0 : 8)
            .ignoresSafeArea()
            
        }
        .onAppear {
            startAnimations()
        }
    }
    
    
    private func startAnimations() {
        // Reset states
        showTitle = false
        showBody = false
        showButton = false
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + staggerDelay) {
            withAnimation(Animation.easeOut(duration: animationDuration)) {
                showTitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + staggerDelay * 1.5) {
            withAnimation(Animation.easeOut(duration: animationDuration)) {
                showBody = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + staggerDelay * 2) {
            withAnimation(Animation.easeOut(duration: animationDuration)) {
                showButton = true
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(isPresented: .constant(true))
    }
}
