import Testing
import MarketData
@testable import QuantEngine

/// Minimal indicator used to verify the protocol's batch/stream contract.
private struct CloseEcho: Indicator {
    var seen = 0
    mutating func update(with bar: Bar) -> Double? {
        seen += 1
        return seen < 2 ? nil : bar.close
    }
    mutating func reset() { seen = 0 }
}

@Suite("Indicator protocol")
struct IndicatorProtocolTests {
    @Test func batchComputeIsIndexAlignedAndResets() {
        let bars = (0..<3).map { Bar(time: Int64($0), open: 1, high: 1, low: 1, close: Double($0), volume: 1) }
        var indicator = CloseEcho()
        _ = indicator.update(with: bars[0])
        #expect(indicator.compute(bars) == [nil, 1, 2])
    }
}
