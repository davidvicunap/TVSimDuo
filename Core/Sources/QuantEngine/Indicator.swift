import MarketData

/// A streaming technical indicator.
///
/// Every indicator supports incremental updates (`update(with:)`, O(1) per bar for
/// live charts) and a batch path (`compute(_:)`) used for history and backtests.
/// The two paths must produce identical values; tests enforce this.
public protocol Indicator: Sendable {
    associatedtype Output: Sendable

    /// Feeds one completed bar and returns the indicator value for it, or `nil`
    /// while the indicator is still warming up.
    mutating func update(with bar: Bar) -> Output?

    /// Clears all internal state.
    mutating func reset()
}

extension Indicator {
    /// Batch evaluation over a bar series. Output is index-aligned with `bars`.
    public func compute(_ bars: some Sequence<Bar>) -> [Output?] {
        var copy = self
        copy.reset()
        return bars.map { copy.update(with: $0) }
    }
}
