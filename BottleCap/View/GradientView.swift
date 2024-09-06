//
//  GradientView.swift
//  Bottle Cap
//
//  Created by Richard Picot on 05/07/2024.
//

import SwiftUI

struct GradientView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.gradientBackgroundPrimaryLeading, Color.gradientBackgroundPrimaryTrailing]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    GradientView()
}


