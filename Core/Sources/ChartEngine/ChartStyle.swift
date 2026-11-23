/// How price data is drawn in a chart pane.
public enum ChartStyle: String, Sendable, Codable, CaseIterable {
    case candles
    case heikinAshi
    case renko
    case footprint
    case line
}
