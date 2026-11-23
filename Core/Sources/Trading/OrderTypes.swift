import MarketData

public enum OrderSide: String, Sendable, Codable, CaseIterable {
    case buy
    case sell

    /// +1 for buy, -1 for sell.
    public var sign: Double { self == .buy ? 1 : -1 }
    public var opposite: OrderSide { self == .buy ? .sell : .buy }
}

public enum OrderType: String, Sendable, Codable, CaseIterable {
    case market
    case limit
    case stop
    case stopLimit
}

public enum TimeInForce: String, Sendable, Codable, CaseIterable {
    case gtc
    case day
    case ioc
}
