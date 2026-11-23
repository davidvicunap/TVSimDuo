// Core market-data domain types shared by every DuoCore module.
//
// Prices and sizes are `Double` for throughput in charting and indicator math;
// exchange-precision rounding happens at the edges via `Instrument.roundPrice`
// and `Instrument.roundQuantity`.

/// Milliseconds since the Unix epoch (UTC).
public typealias Timestamp = Int64

/// A tradable instrument and its exchange precision rules.
public struct Instrument: Hashable, Sendable, Codable, Identifiable, CustomStringConvertible {
    public enum AssetClass: String, Sendable, Codable, CaseIterable {
        case crypto, equity, future, forex, option
    }

    /// Canonical symbol, e.g. `"BTC-USD"`.
    public let id: String
    public let assetClass: AssetClass
    /// Minimum price increment.
    public let tickSize: Double
    /// Minimum quantity increment.
    public let lotSize: Double
    /// Currency value of a 1.0 price move for 1.0 quantity (1 for spot, e.g. 50 for ES futures).
    public let contractMultiplier: Double

    public init(
        id: String,
        assetClass: AssetClass,
        tickSize: Double,
        lotSize: Double,
        contractMultiplier: Double = 1
    ) {
        precondition(tickSize > 0 && lotSize > 0 && contractMultiplier > 0, "Instrument increments must be positive")
        self.id = id
        self.assetClass = assetClass
        self.tickSize = tickSize
        self.lotSize = lotSize
        self.contractMultiplier = contractMultiplier
    }

    public var description: String { id }

    /// Rounds a price to the nearest valid tick.
    public func roundPrice(_ price: Double) -> Double {
        (price / tickSize).rounded() * tickSize
    }

    /// Rounds a quantity *down* to a whole number of lots (never oversizes a position).
    public func roundQuantity(_ quantity: Double) -> Double {
        // Small epsilon absorbs binary floating-point error such as 0.3 / 0.1 = 2.9999999999999996.
        (quantity / lotSize + 1e-9).rounded(.down) * lotSize
    }
}

/// Bar interval. Raw value is the duration in seconds.
public enum Timeframe: Int, Sendable, Codable, CaseIterable, Comparable, CustomStringConvertible {
    case s1 = 1
    case s5 = 5
    case m1 = 60
    case m5 = 300
    case m15 = 900
    case h1 = 3_600
    case h4 = 14_400
    case d1 = 86_400

    public var seconds: Int { rawValue }
    public var milliseconds: Int64 { Int64(rawValue) * 1_000 }

    /// Start of the bucket containing `timestamp` (UTC-aligned).
    public func bucketStart(for timestamp: Timestamp) -> Timestamp {
        let ms = milliseconds
        // Floor division that is also correct for pre-epoch (negative) timestamps.
        let q = timestamp / ms
        return (timestamp % ms < 0 ? q - 1 : q) * ms
    }

    public static func < (lhs: Timeframe, rhs: Timeframe) -> Bool { lhs.rawValue < rhs.rawValue }

    public var description: String {
        switch self {
        case .s1: "1s"
        case .s5: "5s"
        case .m1: "1m"
        case .m5: "5m"
        case .m15: "15m"
        case .h1: "1h"
        case .h4: "4h"
        case .d1: "1D"
        }
    }
}

/// Which side initiated a trade (the aggressor).
public enum AggressorSide: UInt8, Sendable, Codable {
    case buy
    case sell
}

/// A single executed trade print.
public struct Tick: Sendable, Equatable, Codable {
    public var timestamp: Timestamp
    public var price: Double
    public var size: Double
    public var side: AggressorSide

    public init(timestamp: Timestamp, price: Double, size: Double, side: AggressorSide) {
        self.timestamp = timestamp
        self.price = price
        self.size = size
        self.side = side
    }
}

/// An OHLCV bar with aggressor-split volume (enables CVD and footprint views).
public struct Bar: Sendable, Equatable, Codable {
    /// Bucket start time.
    public var time: Timestamp
    public var open: Double
    public var high: Double
    public var low: Double
    public var close: Double
    public var volume: Double
    public var buyVolume: Double
    public var sellVolume: Double

    public init(
        time: Timestamp,
        open: Double,
        high: Double,
        low: Double,
        close: Double,
        volume: Double,
        buyVolume: Double = 0,
        sellVolume: Double = 0
    ) {
        self.time = time
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
        self.buyVolume = buyVolume
        self.sellVolume = sellVolume
    }

    /// Opens a new bar from the first tick of a bucket.
    public init(bucket: Timestamp, firstTick tick: Tick) {
        self.init(time: bucket, open: tick.price, high: tick.price, low: tick.price, close: tick.price, volume: 0)
        apply(tick)
    }

    /// Folds a tick into this bar.
    public mutating func apply(_ tick: Tick) {
        high = max(high, tick.price)
        low = min(low, tick.price)
        close = tick.price
        volume += tick.size
        switch tick.side {
        case .buy: buyVolume += tick.size
        case .sell: sellVolume += tick.size
        }
    }

    /// Buy minus sell aggressor volume for this bar.
    public var delta: Double { buyVolume - sellVolume }
    /// Typical price (H+L+C)/3, used by VWAP.
    public var typicalPrice: Double { (high + low + close) / 3 }
    public var isBullish: Bool { close >= open }
}

/// One price level of an order book.
public struct BookLevel: Sendable, Equatable, Codable {
    public var price: Double
    public var size: Double

    public init(price: Double, size: Double) {
        self.price = price
        self.size = size
    }
}

/// A full-depth order book snapshot. Bids are sorted descending, asks ascending.
public struct OrderBookSnapshot: Sendable, Equatable, Codable {
    public var timestamp: Timestamp
    public var bids: [BookLevel]
    public var asks: [BookLevel]

    public init(timestamp: Timestamp, bids: [BookLevel], asks: [BookLevel]) {
        self.timestamp = timestamp
        self.bids = bids
        self.asks = asks
    }

    public var bestBid: Double? { bids.first?.price }
    public var bestAsk: Double? { asks.first?.price }

    public var midPrice: Double? {
        guard let bid = bestBid, let ask = bestAsk else { return nil }
        return (bid + ask) / 2
    }

    public var spread: Double? {
        guard let bid = bestBid, let ask = bestAsk else { return nil }
        return ask - bid
    }
}

extension Timeframe {
    /// Parses a display label such as `"5m"`, `"1h"` or `"1D"` (case-insensitive).
    public init?(label: String) {
        let needle = label.lowercased()
        guard let match = Timeframe.allCases.first(where: { $0.description.lowercased() == needle }) else { return nil }
        self = match
    }
}
