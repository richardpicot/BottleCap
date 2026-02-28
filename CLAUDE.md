# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BottleCap is a native iOS app (Swift/SwiftUI) for tracking alcoholic beverage consumption via Apple HealthKit. Published on the App Store (ID: 6473561114). Bundle ID: `co.richardp.BottleCap`.

## Build & Run

This is an Xcode project with no external dependencies — only Apple frameworks (SwiftUI, HealthKit, StoreKit, UIKit).

```bash
# Open in Xcode
open "Bottle Cap.xcodeproj"

# Build from command line (requires Xcode, not just Command Line Tools)
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "Bottle Cap.xcodeproj" -scheme "Bottle Cap" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

There are no tests, no linter, no package manager, and no CI/CD pipeline.

## Architecture

MVVM pattern. All source code lives in `BottleCap/`.

**App lifecycle**: `BottleCap.swift` (@main entry) → `AppDelegate.swift` / `SceneDelegate.swift` handle lifecycle and quick actions.

**Model layer** (`Model/`):
- `HealthKitManager.swift` — `@MainActor` class with async/await methods for all HealthKit read/write/delete operations on `numberOfAlcoholicBeverages`. Single instance owned by `BottleCap.swift`, injected via `@EnvironmentObject`.
- `AppSettings.swift` — `ObservableObject` singleton wrapping shared `UserDefaults(suiteName: "group.co.richardp.BottleCap")` for preferences (week start day, drink limit, onboarding flags). Also injected via `@EnvironmentObject`.
- `DrinkData.swift` — Value types (`DailyDrinkTotal`, `WeeklyDrinkTotal`, `MonthlyDrinkGroup`) for structured drink data. No HealthKit dependency — shareable with widget extensions.
- `DrinkDataService.swift` — Static functions to transform raw `HKQuantitySample` arrays into the `DrinkData` model types (daily aggregation, weekly/monthly grouping).
- `Extensions.swift` — Calendar/Date helpers for week boundary calculations.

**View layer** (`View/`):
- `ContentView.swift` — Main screen with drink counter, progress visualization, and navigation. Largest file (~540 lines). Has iOS 26 glass-effect menu overlay and pre-26 `Menu` fallback.
- `LogDrinksView.swift` — Sheet for logging multiple drinks at once.
- `SettingsView.swift` — Preferences (week start, drink limit) and legal links.
- `HistoryView.swift` / `WeeklyDetailView.swift` — Historical data browsing with monthly grouping.
- `WelcomeView.swift` / `HealthAccessView.swift` — Onboarding flow.
- `BackgroundView.swift` / `BubbleEffectView.swift` / `GradientView.swift` — Animated visual effects tied to drink progress.

**Quick Actions**: Home screen shortcuts defined in `Info.plist`, handled via `QuickActionType.swift` and `SceneDelegate.swift`.

**Widget extension** (`BottleCapWidgetExtension/`):
- `BottleCapWidget.swift` — `@main` widget entry point with `AppIntentConfiguration`, `AppIntentTimelineProvider` (reads from shared UserDefaults, refreshes at next week boundary), and `DrinkEntry` timeline entry. Also defines three Control Center controls (`LogDrinkControl`, `OpenLogFormControl`, `OpenAppControl`) and the `WidgetBundle`.
- `BottleCapWidgetEntryView.swift` — Widget UI with gradient background (light) / system background (dark) and configurable plus button. Small widget conditionally renders `Button(intent:)` or `Link` based on the user's `plusAction` config. Lock screen shortcut conditionally sets `widgetURL`.
- `LogDrinkIntent.swift` — `AppIntent` for the interactive plus button. Optimistically increments `widgetDrinkCount` in shared UserDefaults and queues a timestamp in `pendingDrinkLogs` for the main app to process into HealthKit on next foreground.
- `Info.plist` — Widget extension point identifier (`com.apple.widgetkit-extension`).
- Source files also exist in `BottleCapWidget/` (original creation directory) — the Xcode project references files from `BottleCapWidgetExtension/` via a synchronized root group.

**Shared intents** (`Model/LogDrinkOpenIntent.swift` — dual target membership):
- `WidgetPlusAction` — `AppEnum` with `.logADrink` / `.logDrinks` for widget config picker.
- `BottleCapWidgetConfigIntent` — `WidgetConfigurationIntent` with a `plusAction` parameter (default `.logADrink`).
- `LogDrinkOpenIntent` — `OpenIntent` for CC "Log a Drink" control (logs a drink + opens app).
- `OpenLogFormIntent` — `OpenIntent` for CC "Log Drinks..." control (sets `pendingShowLogForm` flag, app opens to `LogDrinksView`).
- `OpenAppIntent` — `OpenIntent` for CC "Open Bottle Cap" control (no-op perform, just opens app).

## Widget Data Flow

```
Main App                          Shared UserDefaults                Widget / CC
─────────                         ──────────────────                ───────────
HealthKit ──read──►               "widgetDrinkCount": 4.0          ──read──► Display
                    ──write──►    "widgetDrinkLimit": 14.0
                                  "widgetWeekStartDay": "monday"
                                  "pendingDrinkLogs": [...]         ◄──write── + Button (LogDrinkIntent)
                                  "pendingShowLogForm": Bool        ◄──write── CC "Log Drinks..." (OpenLogFormIntent)
```

- Widgets cannot access HealthKit directly (Apple sandbox restriction).
- Main app syncs current week total to shared UserDefaults after every drink update (`ContentView.syncToWidget()`).
- Widget plus button: optimistically increments count + queues a pending log entry via `LogDrinkIntent`.
- Main app processes pending logs on foreground (`HealthKitManager.processPendingWidgetLogs()`), writes them to HealthKit, then re-syncs.
- `AppSettings.drinkLimit` and `weekStartDay` didSet handlers also write widget keys and call `WidgetCenter.shared.reloadAllTimelines()`.
- CC "Log Drinks..." control sets `pendingShowLogForm` flag; `ContentView.checkPendingLogForm()` reads/clears it on foreground and opens `LogDrinksView`.
- URL scheme `bottlecap://log` triggers quick log; `bottlecap://logMultiple` opens the log form. Routed in `BottleCap.swift` via `onOpenURL`.

## Key Details

- **Minimum deployment target**: iOS 18.6, with iOS 26-specific UI enhancements (glass effects) behind availability checks. Widget extension also targets iOS 18.6.
- **Data storage**: All drink data lives in HealthKit — there is no Core Data, SQLite, or other local persistence. App settings use shared `UserDefaults` via App Group. Widget data is relayed through shared UserDefaults.
- **Dependency injection**: `HealthKitManager` and `AppSettings` are `@StateObject`s in `BottleCap.swift`, passed to all views via `.environmentObject()`. Views consume them with `@EnvironmentObject` — never create their own instances.
- **Concurrency**: `HealthKitManager` is `@MainActor` with async/await. Views call async methods inside `Task { }` blocks.
- **App Group**: `group.co.richardp.BottleCap` — shared container for `UserDefaults` used by both the main app and widget extension.
- **Entitlements**: Main app: HealthKit access + background delivery, App Groups, associated domains (`applinks:richardp.co`). Widget extension: App Groups only.
- **Assets**: Custom colors (Background, Fill, Gradient) with light/dark variants in `Assets.xcassets`. Shared with widget target via target membership.
- **Bundle IDs**: Main app: `co.richardp.BottleCap`. Widget: `co.richardp.BottleCap.BottleCapWidgetExtension`.
