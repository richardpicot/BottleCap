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
- `ContentView.swift` — Main screen with drink counter, progress visualization, and navigation. Largest file (~524 lines).
- `LogDrinksView.swift` — Sheet for logging multiple drinks at once.
- `SettingsView.swift` — Preferences (week start, drink limit) and legal links.
- `HistoryView.swift` / `WeeklyDetailView.swift` — Historical data browsing with monthly grouping.
- `WelcomeView.swift` / `HealthAccessView.swift` — Onboarding flow.
- `BackgroundView.swift` / `BubbleEffectView.swift` / `GradientView.swift` — Animated visual effects tied to drink progress.

**Quick Actions**: Home screen shortcuts defined in `Info.plist`, handled via `QuickActionType.swift` and `SceneDelegate.swift`.

## Key Details

- **Minimum deployment target**: iOS 18.6, with iOS 26-specific UI enhancements (glass effects) behind availability checks.
- **Data storage**: All drink data lives in HealthKit — there is no Core Data, SQLite, or other local persistence. App settings use shared `UserDefaults` via App Group.
- **Dependency injection**: `HealthKitManager` and `AppSettings` are `@StateObject`s in `BottleCap.swift`, passed to all views via `.environmentObject()`. Views consume them with `@EnvironmentObject` — never create their own instances.
- **Concurrency**: `HealthKitManager` is `@MainActor` with async/await. Views call async methods inside `Task { }` blocks.
- **App Group**: `group.co.richardp.BottleCap` — shared container for `UserDefaults` so a future widget extension can access settings.
- **Entitlements**: HealthKit access + background delivery, App Groups, associated domains (`applinks:richardp.co`).
- **Assets**: Custom colors (Background, Fill, Gradient) with light/dark variants in `Assets.xcassets`.
