//
//  WidgetEducationView.swift
//  Bottle Cap
//
//  Created by Richard Picot on 28/03/2026.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Widgets are here!")
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 4)

            Image("WidgetAnnouncement")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 24)

            Text("Keep tabs on your drinks without opening the app. Add Bottle Cap to your Home Screen, Lock Screen, or Control Center.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            Group {
                if #available(iOS 26, *) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Got it")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Text("Got it")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(Capsule())
                    .controlSize(.large)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 40)
        .presentationDetents([.height(520)])
        .presentationDragIndicator(.visible)

    }
}

#Preview {
    WhatsNewView()
}
