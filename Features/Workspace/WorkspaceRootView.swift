import SwiftUI
import MarketData

/// The single, persistent root of the app's view hierarchy.
///
/// Uses the system `TabView` and one `NavigationStack` per tab so that, on iPhone Duo,
/// iOS docks tabs and toolbar items into the vertical side bar automatically.
/// There is deliberately no folded / unfolded branching here: every posture renders
/// this same tree and adapts from layout geometry (see `Foldable/`).
struct WorkspaceRootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        TabView(selection: $model.selectedTab) {
            Tab("Trade", systemImage: "chart.xyaxis.line", value: AppModel.Tab.trade) {
                NavigationStack {
                    TradeWorkspacePlaceholder()
                }
            }

            Tab("Markets", systemImage: "list.bullet.rectangle", value: AppModel.Tab.markets) {
                NavigationStack {
                    ContentUnavailableView("Markets", systemImage: "list.bullet.rectangle", description: Text("Watchlist and screener arrive in Phase 7."))
                        .navigationTitle("Markets")
                }
            }

            Tab("Alerts", systemImage: "bell", value: AppModel.Tab.alerts) {
                NavigationStack {
                    ContentUnavailableView("Alerts", systemImage: "bell", description: Text("Local alert rules arrive in Phase 2."))
                        .navigationTitle("Alerts")
                }
            }

            #if DEBUG
            Tab("Fold", systemImage: "rectangle.split.2x1", value: AppModel.Tab.diagnostics) {
                NavigationStack {
                    FoldDiagnosticsView()
                }
            }
            #endif
        }
        .toolbarVerticalBehavior(.automatic)
    }
}

/// Stand-in for the trading workspace until Phase 3.
private struct TradeWorkspacePlaceholder: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 12) {
            Text(model.focusedSymbol)
                .font(.largeTitle.monospaced().bold())
                .accessibilityIdentifier("workspace.symbol")
            Text(model.focusedTimeframe.description)
                .font(.title3.monospaced())
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("workspace.timeframe")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Trade")
    }
}
