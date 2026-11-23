import Foundation
import Observation
import MarketData
import Trading
import WorkspaceModel

/// Root state container, owned by the `App` and shared by every scene.
///
/// Feature stores (charts, order drafts, watchlists) hang off this object so that
/// view identity changes caused by layout reflow can never discard them.
@MainActor
@Observable
final class AppModel {
    enum Tab: Hashable {
        case trade
        case markets
        case alerts
        case diagnostics
    }

    var selectedTab: Tab = .trade
    /// Symbol the trade workspace is focused on.
    var focusedSymbol: String = "BTC-USD"
    /// Timeframe of the focused chart.
    var focusedTimeframe: Timeframe = .m5
    /// Side preselected when a deep link opens the ticket.
    var pendingTicketSide: OrderSide?
    /// Last URL that could not be routed, surfaced for diagnostics.
    private(set) var lastRejectedURL: URL?

    /// Routes a `duotrade://` URL into app state.
    func handle(url: URL) {
        guard let link = DeepLink(url: url) else {
            lastRejectedURL = url
            return
        }
        apply(link)
    }

    func apply(_ link: DeepLink) {
        switch link {
        case let .chart(symbol, timeframe):
            selectedTab = .trade
            focusedSymbol = symbol
            if let timeframe { focusedTimeframe = timeframe }
        case let .ticket(symbol, side):
            selectedTab = .trade
            focusedSymbol = symbol
            pendingTicketSide = side
        case .alerts:
            selectedTab = .alerts
        }
    }
}
