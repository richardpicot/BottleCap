//
//  BackgroundFillView.swift
//  HealthKitAlcoholTest
//
//  Created by Richard Picot on 23/10/2023.
//

import SwiftUI

struct BackgroundView: View {
    var progress: CGFloat  // A number between 0 and 1
    
    var body: some View {
        
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let totalWidth = geometry.size.width
            let progressHeight = totalHeight * progress
            
            VStack {
                ZStack(alignment: .bottom) {
                    Color.backgroundPrimary
                    
                    Rectangle()
                        .fill(.backgroundSecondary)
                        .frame(width: totalWidth, height: totalHeight)
                        .mask(
                            VStack {
                                Rectangle().frame(height: progressHeight)
                            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        )
                }
            }
        }
        .ignoresSafeArea()
        .animation(.spring(duration: 1.0, bounce: 0.4), value: progress)
    }
}

#Preview {
    BackgroundView(progress: 0.5)
}
