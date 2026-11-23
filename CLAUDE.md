# DuoTrade — iPhone Duo trading app (iOS 27.1+, Swift 6, SwiftUI)

## Project rules
- **Build & test:** `xcodebuild test -scheme DuoTrade -destination 'platform=iOS Simulator,name=iPhone Duo'`
- **Banned APIs:** never use `UIScreen.main`, `UIDevice.current.orientation`, `statusBarOrientation` or `userInterfaceIdiom` checks. Enforced by `scripts/audit-banned-apis.sh`.
- **Foldable layout:** always lay out with `ArrangementView` and `GeometryProxy` reserved regions (`.division`, `.occlusion`). Use `onHingeChange` only for haptics and animations.
- **State continuity:** never branch into separate view trees for folded and unfolded states. Keep one adaptive hierarchy so chart zoom and draft orders survive fold transitions. Durable state lives in `@Observable` stores owned by `AppModel`, never in view `@State`.
- **Toolbars:** always use the system `NavigationStack`, `TabView` and `.toolbar` so vertical side-bar docking works automatically on iPhone Duo.
- **Execution:** paper trading only. No real order routing.

## Layout
| Path | Contents |
|---|---|
| `DuoTrade.xcodeproj` | Xcode 16+ synchronized folders. Targets: `DuoTrade` (app), `DuoTradeWidgets`, `DuoTradeTests`, `DuoTradeUITests` |
| `App/` | `@main` scene entry, `AppModel`, assets |
| `Features/` | SwiftUI features. Every iOS 27.1 Duo API call lives in `Features/Workspace/Foldable/` |
| `Shared/` | Code compiled into both the app and the widget extension |
| `Widgets/` | WidgetKit, Live Activity and Dynamic Island extension |
| `Core/` | Local Swift package `DuoCore`: MarketData, QuantEngine, Trading, ChartEngine, WorkspaceModel (pure Swift, Linux-testable), plus ChartRendering and ScriptRuntime (Apple-only) |
| `Tests/` | Hosted unit tests (`DuoTradeTests`) and UI tests (`DuoTradeUITests`) |
| `Config/` | Info.plist files |

## Commands
```sh
# Full app build + all tests (app, UI, and Core package tests via the shared scheme)
xcodebuild test -scheme DuoTrade -destination 'platform=iOS Simulator,name=iPhone Duo'

# Core engines only (works on macOS and Linux)
cd Core && swift build && swift test

# Banned-API audit (must print 0 occurrences)
scripts/audit-banned-apis.sh
```

## iPhone Duo API surface (iOS 27.1)
These are the signatures the code assumes. `Features/Workspace/Foldable/FoldDiagnosticsView.swift` calls each one, so the compiler confirms them.
- `ArrangementView { primary } secondary: { secondary }` with `.arrangementViewStyle(.split.axes(Axis.Set))`, a custom `ArrangementViewStyle` (`configuration.primary` / `.secondary`), and `.splitArrangementLayoutRatio(Double)` on the primary pane
- `proxy.reservedRegions(kind: .division | .occlusion, options: [.includeInactive])`, returning `ReservedRegion` values with `frame`, `margins` and `isActive`
- `.onHingeChange { old, new in new.hinge }`. `DeviceHinge?` exposes `.status` (`.closed`, `.partiallyOpen`, `.fullyOpen`) and `.angle`
- `TabView.toolbarVerticalBehavior(.automatic | .disabled)`; on `ToolbarItem`: `.axisBehavior(.verticalPreferred)` and `.visibilityPriority(_:)`; `ToolbarOverflowMenu { }`; `@Environment(\.toolbarVerticalEdge)`

## Testing poses in Xcode Device Hub
1. Run the `DuoTrade` scheme on the **iPhone Duo** simulator.
2. Open Device Hub (`Xcode.app/Contents/Applications/DeviceHub.app`) and select the booted iPhone Duo.
3. In DEBUG builds the **Fold** tab overlays live reserved regions and hinge status. Use it to confirm each pose:

| Pose | Device Hub action | Expected DuoTrade layout |
|---|---|---|
| **Closed** (cover display) | Closed | Single chart, compact ticker strip and swipe-to-submit ticket. No division region. |
| **Fully open** | Open | Multi-chart grid with docked DOM, Watchlist and Screener. No active division. |
| **Book** | Partially Open, portrait | Chart on one side of the 40 pt vertical division, order book and ticket on the other. Nothing crosses the fold. |
| **Tabletop** | Partially Open, then rotate (⌘← / ⌘→) | Chart and heatmap on the upper half, DOM, hotkeys and calculator on the lower half. You feel a haptic detent on entering this pose (on device). |

At every transition, check that the chart zoom, crosshair, timeframe, indicators and any draft order are unchanged.
