# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BottleCap is a native iOS app (Swift/SwiftUI) for tracking alcoholic beverage consumption via Apple HealthKit. Published on the App Store (ID: 6473561114). Bundle ID: `co.richardp.BottleCap`.

## Build & Run

This is an Xcode project with no external dependencies — only Apple frameworks (SwiftUI, HealthKit, StoreKit, UIKit).

```bash
# Open in Xcode
open "Bottle Cap.xcodeproj"

# Build from command line
xcodebuild -project "Bottle Cap.xcodeproj" -scheme "Bottle Cap" -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16'
```

There are no tests, no linter, no package manager, and no CI/CD pipeline.

## Architecture

MVVM pattern. All source code lives in `BottleCap/`.

**App lifecycle**: `BottleCap.swift` (@main entry) → `AppDelegate.swift` / `SceneDelegate.swift` handle lifecycle and quick actions.

**Model layer** (`Model/`):
- `HealthKitManager.swift` — All HealthKit read/write/delete operations for `numberOfAlcoholicBeverages`. This is the core data layer; there is no local database.
- `AppSettings.swift` — Singleton wrapping UserDefaults for preferences (week start day, drink limit, onboarding flags).
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

- **Minimum deployment target**: iOS 17.0, with iOS 26-specific UI enhancements (glass effects) behind availability checks.
- **Data storage**: All drink data lives in HealthKit — there is no Core Data, SQLite, or other local persistence. App settings use UserDefaults.
- **Entitlements**: HealthKit access + background delivery, associated domains (`applinks:richardp.co`).
- **Assets**: Custom colors (Background, Fill, Gradient) with light/dark variants in `Assets.xcassets`.
