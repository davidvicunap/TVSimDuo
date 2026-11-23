# DuoTrade (TVSimDuo)

DuoTrade is a native trading, technical-analysis and market-intelligence app for iPhone Duo. It requires iOS 27.1+ and is written in Swift 6 and SwiftUI, with no WebViews.

The UI adapts to all four iPhone Duo poses: Closed (cover display), Fully Open, Book and Tabletop. It does this with one view hierarchy, laid out from `ArrangementView` and reserved regions, so chart zoom and draft orders survive every fold.

- **Build:** `xcodebuild test -scheme DuoTrade -destination 'platform=iOS Simulator,name=iPhone Duo'`
- **Core engines:** `cd Core && swift test`. This also runs on Linux.
- **Rules, layout and the Device Hub pose walkthrough:** see [CLAUDE.md](CLAUDE.md).

Order execution is **paper trading only**.
