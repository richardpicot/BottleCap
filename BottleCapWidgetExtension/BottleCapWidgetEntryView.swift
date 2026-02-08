//
//  BottleCapWidgetEntryView.swift
//  BottleCapWidget
//
//  Widget UI for home screen and lock screen widgets.
//

import SwiftUI
import WidgetKit
import AppIntents

struct BottleCapWidgetEntryView: View {
    var entry: DrinkEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Home Screen Small Widget

private struct SmallWidgetView: View {
    var entry: DrinkEntry

    private var remaining: Double {
        entry.drinkLimit - entry.drinkCount
    }

    private var formattedRemaining: String {
        let value = abs(remaining)
        let rounded = (value * 10).rounded() / 10
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", rounded)
        } else {
            return String(format: "%.1f", rounded)
        }
    }

    // 1 = under, 0 = reached, -1 = over
    private var subtitleState: Int {
        if remaining > 0 { return 1 }
        if remaining == 0 { return 0 }
        return -1
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Text content with standard padding
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.drinkCount == 1 ? "Drink this week" : "Drinks this week")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.textPrimary)

                Text(entry.formattedCount)
                    .font(.system(size: 42, weight: .regular))
                    .foregroundStyle(.textPrimary)
                    .contentTransition(.numericText(value: entry.drinkCount))
                    .invalidatableContent()

                Spacer()

                // Subtitle: number animates independently, full view
                // transitions only when state changes (under → reached → over)
                Group {
                    switch subtitleState {
                    case 1:
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                                Text(formattedRemaining)
                                    .contentTransition(.numericText(value: remaining))
                                Text(" more until")
                            }
                            Text("your limit")
                        }
                    case 0:
                        VStack(alignment: .leading, spacing: 0) {
                            Text("You've reached")
                            Text("your limit")
                        }
                    default:
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                                Text(formattedRemaining)
                                    .contentTransition(.numericText(value: -remaining))
                                Text(" over")
                            }
                            Text("your limit")
                        }
                    }
                }
                .id(subtitleState)
                .transition(.push(from: .bottom))
                .font(.footnote)
                .foregroundStyle(.textPrimary)
                .opacity(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // + button concentric with widget corner
            Button(intent: LogDrinkIntent()) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.gradientButtonPrimaryLeading, .gradientButtonPrimaryTrailing],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
            }
            .buttonStyle(.plain)
        }
        .containerBackground(for: .widget) {
            Color.backgroundPrimary
        }
    }
}

// MARK: - Lock Screen Circular Widget

private struct CircularWidgetView: View {
    var entry: DrinkEntry

    var body: some View {
        Gauge(value: entry.progress) {
            Text("Drinks")
        } currentValueLabel: {
            Text(entry.formattedCount)
                .font(.system(.title3, weight: .semibold))
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Lock Screen Rectangular Widget

private struct RectangularWidgetView: View {
    var entry: DrinkEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(entry.formattedCount) \(entry.drinkCount == 1 ? "drink" : "drinks") this week")
                .font(.headline)
                .widgetAccentable()

            ProgressView(value: entry.progress)
        }
        .containerBackground(.clear, for: .widget)
    }
}
