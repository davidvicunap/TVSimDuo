import Foundation
import Testing
import MarketData
@testable import DuoTrade

/// Hosted tests that run inside the DuoTrade app process.
///
/// Core package products are statically linked into the app, so these tests only
/// assert through symbols the app itself uses (engine logic is covered by the
/// Core package's own test targets).
@MainActor
@Suite("App model")
struct AppModelTests {
    @Test func chartDeepLinkFocusesSymbolAndTimeframe() throws {
        let model = AppModel()
        model.selectedTab = .markets
        model.handle(url: try #require(URL(string: "duotrade://chart/ETH-USD?tf=1h")))
        #expect(model.selectedTab == .trade)
        #expect(model.focusedSymbol == "ETH-USD")
        #expect(model.focusedTimeframe.description == "1h")
    }

    @Test func sharedLinkBuilderRoundTripsThroughParser() {
        let model = AppModel()
        model.handle(url: DuoTradeLinks.chart(symbol: "SOL-USD", timeframe: "15m"))
        #expect(model.focusedSymbol == "SOL-USD")
        #expect(model.focusedTimeframe.description == "15m")
        #expect(model.lastRejectedURL == nil)
    }

    @Test func invalidLinkIsRecordedNotApplied() throws {
        let model = AppModel()
        let url = try #require(URL(string: "duotrade://nowhere"))
        model.handle(url: url)
        #expect(model.focusedSymbol == "BTC-USD")
        #expect(model.lastRejectedURL == url)
    }
}
