# Widget Redesign Plan

## Context

The current small home screen widget has a WIP design (blue gradient background with fill-up effect, centered 64pt counter). This plan replaces it with the Figma design and adds two lock screen widget sizes — all grouped under a single Widget per Apple HIG guidance.

## Summary of Changes

**3 widget sizes, 1 Widget struct:**
- `.systemSmall` — redesigned home screen widget (per Figma)
- `.accessoryCircular` — lock screen gauge with counter
- `.accessoryRectangular` — lock screen progress bar with text

**2 files modified, 0 files created.**

---

## File 1: `BottleCapWidgetExtension/BottleCapWidget.swift`

### Update supported families

Change `.supportedFamilies([.systemSmall])` to `.supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular])`.

Keep `@main`, `kind`, `Provider`, and `DrinkEntry` unchanged — no `WidgetBundle` needed.

> **Why no WidgetBundle?** Apple HIG: "Group your widget's sizes together, and provide a single description." All three sizes show the same drink data at different fidelities, so they belong in one Widget. This gives a single gallery entry with size options.

### Switch view by family

Use `@Environment(\.widgetFamily)` in the entry view to render the correct layout for each size.

### Add formatting helpers on DrinkEntry

Extract `formattedCount` and `progress` as computed properties on `DrinkEntry` (via extension) to avoid duplication across the three view branches.

### Update previews

Add `#Preview` blocks for `.accessoryCircular` and `.accessoryRectangular` alongside the existing `.systemSmall` preview.

---

## File 2: `BottleCapWidgetExtension/BottleCapWidgetEntryView.swift`

Rewrite to switch on `widgetFamily` and render three distinct layouts.

### .systemSmall — Home screen (redesigned per Figma)

**Two content states:**

| State | Subtitle text |
|---|---|
| Under limit | "X more until\nyour limit" |
| At/over limit | "X over\nyour limit" |

| Aspect | Current | New (Figma) |
|---|---|---|
| Background | Blue gradient + fill-up effect | Solid `Color.backgroundPrimary` |
| Layout | Centered VStack in GeometryReader | Top-left aligned VStack |
| Top label | None | "Drinks this week" (.footnote, semibold) |
| Count | 64pt condensed regular | 42pt regular |
| Subtitle | None | State-dependent text (.footnote, 0.7 opacity) |
| + button | 16pt bold, padded inset | 13pt semibold, concentric with widget corner |

- Remove `GeometryReader`, progress calculation, and fill-up `Rectangle`
- Layout: "Drinks this week" at top → large number below → subtitle pinned to bottom-left
- **+ button concentric with corner**: position the 32x32 button so it sits at the very bottom-trailing edge of the content area, aligned with the widget's rounded corner. Use standard widget padding for all text content, but allow the button to sit at the edge.
- **Number animation**: Apply `.contentTransition(.numericText(value: entry.drinkCount))` to the count `Text` — this gives the system rolling-counter effect when the number changes between timeline entries.
- **Invalidatable content**: Apply `.invalidatableContent()` to the count `Text` — after tapping +, this shows a system shimmer effect on the number while waiting for the timeline to reload with the updated value. Use only on this one view (Apple guidance: use judiciously on meaningful views only).
- `.containerBackground(for: .widget) { Color.backgroundPrimary }` (required per Apple docs — marks background as removable for StandBy/vibrant contexts)

### .accessoryCircular — Lock screen gauge

- `Gauge(value: progress)` with `.accessoryCircularCapacity` gauge style (closed ring that fills proportionally)
- `currentValueLabel`: drink count number centered in the ring
- Progress = `drinkCount / drinkLimit`, clamped 0...1
- `.containerBackground(.clear, for: .widget)`
- No explicit colors — lock screen renders in `vibrant` mode automatically (monochrome with vibrancy effect)

### .accessoryRectangular — Lock screen progress bar

- `VStack(alignment: .leading)` with text + `ProgressView`
- Text: "X drinks this week" using `.headline` font
- `.widgetAccentable()` on the text — allows tinting in accented rendering mode
- `ProgressView(value: progress)` with default linear style
- `.containerBackground(.clear, for: .widget)`

---

## Apple Documentation Compliance Checklist

- [x] `.containerBackground(for: .widget)` on all views (avoids Xcode warning overlay)
- [x] Single Widget with grouped families (HIG: "Group your widget's sizes together")
- [x] `.widgetAccentable()` on key content for accented rendering mode
- [x] No interactive buttons on lock screen widgets (only `.systemSmall` has the + button)
- [x] Accessory widgets use `.clear` container background (system handles vibrant/monochrome rendering)
- [x] Text at 11pt+ minimum (smallest is 13pt `.footnote`)
- [x] Using SF Pro system font throughout
- [x] `.contentTransition(.numericText(value:))` for animated counter (per WWDC "Bring widgets to life")
- [x] `.invalidatableContent()` on count text — shows system shimmer while timeline reloads after interaction

---

## Verification

1. Build: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "Bottle Cap.xcodeproj" -scheme "Bottle Cap" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
2. Xcode previews: check `#Preview` for all three families
3. Verify `.systemSmall` matches the Figma design (cream background, top-left text, orange + button)
4. Verify `.accessoryCircular` shows gauge ring with counter
5. Verify `.accessoryRectangular` shows "X drinks this week" with progress bar
6. Test interactive + button still works on small widget
7. Verify dark mode appearance for all three sizes
