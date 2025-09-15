import SwiftUI

struct WelcomeView: View {
    @State private var showTermsOfUse = false // State to control the presentation of the TermsOfUseView

    @Binding var isPresented: Bool

    @State private var isRequestingPermission = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
                                    Text("The number of drinks you've logged in a week are front and centre.")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.top, 16)

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }

                // Footer VStack
                VStack(spacing: 24) {
                    Button(action: {
                        showTermsOfUse = true
                    }) {
                        Text("Bottle Cap is for people who want to keep casual tabs on their drinking – not addiction support. If that's you, please check the ")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            +
                            Text("Terms of Use.")
                            .foregroundColor(.textAccent)
                            .font(.footnote)
                    }
                    .sheet(isPresented: $showTermsOfUse) {
                        NavigationStack {
                            TermsOfUseView()
                        }
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.large])
                    }

                    Group {
                        if #available(iOS 26, *) {
                            NavigationLink(destination: HealthAccessView(healthKitManager: HealthKitManager(), isPresented: $isPresented)) {
                                Text("Continue")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .controlSize(.large)
                            }
                            .buttonStyle(.glassProminent)
                            .controlSize(.large)
                        } else {
                            NavigationLink(destination: HealthAccessView(healthKitManager: HealthKitManager(), isPresented: $isPresented)) {
                                Text("Continue")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .controlSize(.large)
                            }
                            .buttonStyle(.borderedProminent)
                            .clipShape(Capsule())
                            .controlSize(.large)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            // Keep inline bar metrics but make the title area visually empty using an empty principal item.
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Color.clear
                        .frame(width: 1, height: 1)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(isPresented: .constant(true))
    }
}
