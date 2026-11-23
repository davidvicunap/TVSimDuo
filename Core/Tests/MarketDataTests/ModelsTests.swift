import Testing
@testable import MarketData

@Suite("Market data models")
struct ModelsTests {
    @Test func timeframeBucketsAlignToUTC() {
        #expect(Timeframe.m5.bucketStart(for: 1_700_000_123_456) == 1_700_000_100_000)
        #expect(Timeframe.h1.bucketStart(for: 3_600_000) == 3_600_000)
        #expect(Timeframe.m1.bucketStart(for: -1) == -60_000)
    }

    @Test func instrumentRoundsToTickAndLot() {
        let btc = Instrument(id: "BTC-USD", assetClass: .crypto, tickSize: 0.01, lotSize: 0.0001)
        #expect(abs(btc.roundPrice(100.006) - 100.01) < 1e-9)
        #expect(abs(btc.roundQuantity(0.00029) - 0.0002) < 1e-12)

        let es = Instrument(id: "ES", assetClass: .future, tickSize: 0.25, lotSize: 1, contractMultiplier: 50)
        #expect(es.roundPrice(5000.13) == 5000.25)
        #expect(es.roundQuantity(2.99) == 2)
        #expect(es.roundQuantity(3.0) == 3)
    }

    @Test func barFoldsTicksWithAggressorSplit() {
        var bar = Bar(bucket: 0, firstTick: Tick(timestamp: 0, price: 10, size: 2, side: .buy))
        bar.apply(Tick(timestamp: 1, price: 12, size: 1, side: .sell))
        bar.apply(Tick(timestamp: 2, price: 9, size: 3, side: .buy))
        #expect(bar.open == 10 && bar.high == 12 && bar.low == 9 && bar.close == 9)
        #expect(bar.volume == 6)
        #expect(bar.delta == 4)
    }

    @Test func bookDerivedPrices() {
        let book = OrderBookSnapshot(
            timestamp: 0,
            bids: [BookLevel(price: 99, size: 1)],
            asks: [BookLevel(price: 101, size: 1)]
        )
        #expect(book.midPrice == 100)
        #expect(book.spread == 2)
    }
}

@Suite("Timeframe labels")
struct TimeframeLabelTests {
    @Test func roundTripsEveryLabel() {
        for timeframe in Timeframe.allCases {
            #expect(Timeframe(label: timeframe.description) == timeframe)
        }
        #expect(Timeframe(label: "1d") == .d1)
        #expect(Timeframe(label: "2m") == nil)
    }
}
