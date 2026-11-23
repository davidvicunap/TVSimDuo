import Foundation

/// Builds `duotrade://` URLs. Shared by the app and the widget extension.
///
/// The app parses these with `WorkspaceModel.DeepLink`; keep both in sync.
enum DuoTradeLinks {
    static let scheme = "duotrade"

    static func chart(symbol: String, timeframe: String? = nil) -> URL {
        url(host: "chart", path: symbol, query: timeframe.map { ["tf": $0] } ?? [:])
    }

    static func ticket(symbol: String, side: String? = nil) -> URL {
        url(host: "ticket", path: symbol, query: side.map { ["side": $0] } ?? [:])
    }

    static var alerts: URL { url(host: "alerts", path: nil, query: [:]) }

    private static func url(host: String, path: String?, query: [String: String]) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        if let path { components.path = "/" + path }
        if !query.isEmpty {
            components.queryItems = query.sorted { $0.key < $1.key }.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components.url else {
            preconditionFailure("Invalid DuoTrade link components: \(components)")
        }
        return url
    }
}
