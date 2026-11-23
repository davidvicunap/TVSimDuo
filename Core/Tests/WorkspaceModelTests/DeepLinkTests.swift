import Foundation
import Testing
import MarketData
import Trading
@testable import WorkspaceModel

@Suite("Deep links")
struct DeepLinkTests {
    @Test func parsesChartWithTimeframe() throws {
        let url = try #require(URL(string: "duotrade://chart/btc-usd?tf=5m"))
        #expect(DeepLink(url: url) == .chart(symbol: "BTC-USD", timeframe: .m5))
    }

    @Test func parsesTicketWithSide() throws {
        let url = try #require(URL(string: "DuoTrade://ticket/ETH-USD?side=SELL"))
        #expect(DeepLink(url: url) == .ticket(symbol: "ETH-USD", side: .sell))
    }

    @Test func unknownTimeframeIsIgnoredNotFatal() throws {
        let url = try #require(URL(string: "duotrade://chart/BTC-USD?tf=7m"))
        #expect(DeepLink(url: url) == .chart(symbol: "BTC-USD", timeframe: nil))
    }

    @Test(arguments: ["https://chart/BTC-USD", "duotrade://chart", "duotrade://unknown/x"])
    func rejectsInvalidURLs(_ string: String) throws {
        let url = try #require(URL(string: string))
        #expect(DeepLink(url: url) == nil)
    }
}
