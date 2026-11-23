import Foundation
import MarketData
import Trading

/// A parsed `duotrade://` URL.
///
/// Supported forms:
/// - `duotrade://chart/BTC-USD?tf=5m` — focus a chart on a symbol and optional timeframe
/// - `duotrade://ticket/BTC-USD?side=buy` — open the order ticket prefilled
/// - `duotrade://alerts` — open the alerts list
public enum DeepLink: Equatable, Sendable {
    case chart(symbol: String, timeframe: Timeframe?)
    case ticket(symbol: String, side: OrderSide?)
    case alerts

    public static let scheme = "duotrade"

    public init?(url: URL) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.scheme?.lowercased() == Self.scheme,
            let host = components.host?.lowercased()
        else { return nil }

        let pathParts = components.path.split(separator: "/").map(String.init)
        let query = Dictionary(
            (components.queryItems ?? []).compactMap { item in item.value.map { (item.name.lowercased(), $0) } },
            uniquingKeysWith: { _, last in last }
        )

        switch host {
        case "chart":
            guard let symbol = pathParts.first?.uppercased(), !symbol.isEmpty else { return nil }
            self = .chart(symbol: symbol, timeframe: query["tf"].flatMap(Timeframe.init(label:)))
        case "ticket":
            guard let symbol = pathParts.first?.uppercased(), !symbol.isEmpty else { return nil }
            self = .ticket(symbol: symbol, side: query["side"].flatMap { OrderSide(rawValue: $0.lowercased()) })
        case "alerts":
            self = .alerts
        default:
            return nil
        }
    }
}
