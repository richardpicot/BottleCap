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
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Shared Plus Icon

private struct PlusIconView: View {
    var body: some View {
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
}

// MARK: - Home Screen Small Widget

private struct SmallWidgetView: View {
    var entry: DrinkEntry

    @Environment(\.colorScheme) private var colorScheme

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

                if entry.isDecimal {
                    (Text(entry.wholePartString)
                        .font(.system(size: 42, weight: .medium, design: .rounded))
                    + Text(entry.decimalPartString)
                        .font(.system(size: 26, weight: .medium, design: .rounded)))
                        .foregroundStyle(.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText(value: entry.drinkCount))
                        .invalidatableContent()
                } else {
                    Text(entry.formattedCount)
                        .font(.system(size: 42, weight: .medium, design: .rounded))
                        .foregroundStyle(.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText(value: entry.drinkCount))
                        .invalidatableContent()
                }

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
                .padding(.trailing, 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // + button concentric with widget corner
            switch entry.plusAction {
            case .logADrink:
                Button(intent: LogDrinkIntent()) {
                    PlusIconView()
                }
                .buttonStyle(.plain)
                .padding(.trailing, -5)
                .padding(.bottom, -5)
            case .logDrinks:
                Link(destination: URL(string: "bottlecap://logMultiple")!) {
                    PlusIconView()
                }
                .padding(.trailing, -5)
                .padding(.bottom, -5)
            }
        }
        .containerBackground(for: .widget) {
            if colorScheme == .dark {
                Color(.systemBackground)
            } else {
                LinearGradient(
                    colors: [.gradientBackgroundPrimaryLeading, .gradientBackgroundPrimaryTrailing],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}

// MARK: - Lock Screen Inline Widget

private struct InlineWidgetView: View {
    var entry: DrinkEntry

    var body: some View {
        if entry.drinkCount == 0 {
            Text("No drinks this week 🍺")
        } else {
            Text("\(entry.formattedCount) \(entry.drinkCount == 1 ? "drink" : "drinks") this week")
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

// MARK: - Lock Screen Log Drink Shortcut

struct LogDrinkShortcutView: View {
    var entry: DrinkEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Image("bottlecap.plus")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 24, weight: .semibold))
        }
        .widgetURL(entry.plusAction == .logDrinks
            ? URL(string: "bottlecap://logMultiple")
            : URL(string: "bottlecap://log"))
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Lock Screen Rectangular Widget

private struct RectangularWidgetView: View {
    var entry: DrinkEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if entry.drinkCount == 0 {
                Text("No drinks logged this week 🍺")
                    .font(.headline)
                    .widgetAccentable()
            } else {
                Text("\(entry.formattedCount) \(entry.drinkCount == 1 ? "drink" : "drinks") this week")
                    .font(.headline)
                    .widgetAccentable()

                ProgressView(value: entry.progress)
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}
