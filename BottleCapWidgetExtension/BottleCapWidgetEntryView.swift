//
//  BottleCapWidgetEntryView.swift
//  BottleCapWidget
//
//  Widget UI with fill-up background effect and interactive plus button.
//

import SwiftUI
import WidgetKit
import AppIntents

struct BottleCapWidgetEntryView: View {
    var entry: DrinkEntry

    private var progress: CGFloat {
        guard entry.drinkLimit > 0 else { return 0 }
        return min(CGFloat(entry.drinkCount) / CGFloat(entry.drinkLimit), 1.0)
    }

    private var formattedCount: String {
        let rounded = (entry.drinkCount * 10).rounded() / 10
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", rounded)
        } else {
            return String(format: "%.1f", rounded)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let totalWidth = geometry.size.width

            ZStack(alignment: .bottom) {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.gradientBackgroundPrimaryLeading, Color.gradientBackgroundPrimaryTrailing]),
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Fill effect (solid color from bottom)
                Rectangle()
                    .fill(Color.backgroundSecondary)
                    .frame(width: totalWidth, height: totalHeight * progress)

                // Content
                VStack(spacing: 2) {
                    Spacer()

                    Text(formattedCount)
                        .font(.system(size: 64, weight: .regular, design: .default))
                        .fontWidth(.condensed)
                        .foregroundStyle(.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Text(entry.drinkCount == 1 ? "drink this week" : "drinks this week")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.textPrimary)
                        .opacity(0.8)

                    Spacer()

                    HStack {
                        Spacer()
                        Button(intent: LogDrinkIntent()) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.gradientButtonPrimaryLeading, Color.gradientButtonPrimaryTrailing]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                gradient: Gradient(colors: [Color.gradientBackgroundPrimaryLeading, Color.gradientBackgroundPrimaryTrailing]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
