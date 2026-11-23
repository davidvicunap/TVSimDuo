import SwiftUI
import WidgetKit

/// Glanceable watchlist for the Home Screen, Lock Screen and Always-On cover display.
///
/// Phase 0 shows a static sample so the extension builds and embeds; Phase 7 feeds it
/// real quotes through an App Group snapshot written by the app.
struct WatchlistGlanceWidget: Widget {
    static let kind = "dev.duotrade.watchlist"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: WatchlistProvider()) { entry in
            WatchlistGlanceView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(DuoTradeLinks.chart(symbol: entry.quotes.first?.symbol ?? "BTC-USD"))
        }
        .configurationDisplayName("Watchlist")
        .description("Last prices for your top symbols.")
        .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryInline])
    }
}

struct WatchlistEntry: TimelineEntry {
    struct Quote: Hashable {
        let symbol: String
        let last: Double
        let changePercent: Double
    }

    let date: Date
    let quotes: [Quote]
    /// True until the app has written a real snapshot (Phase 7).
    let isSample: Bool

    static let sample = WatchlistEntry(
        date: .now,
        quotes: [
            Quote(symbol: "BTC-USD", last: 0, changePercent: 0),
            Quote(symbol: "ETH-USD", last: 0, changePercent: 0),
        ],
        isSample: true
    )
}

struct WatchlistProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchlistEntry { .sample }

    func getSnapshot(in context: Context, completion: @escaping (WatchlistEntry) -> Void) {
        completion(.sample)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchlistEntry>) -> Void) {
        completion(Timeline(entries: [.sample], policy: .never))
    }
}

struct WatchlistGlanceView: View {
    let entry: WatchlistEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(entry.quotes.first?.symbol ?? "DuoTrade")
        default:
            VStack(alignment: .leading, spacing: 4) {
                ForEach(entry.quotes, id: \.self) { quote in
                    HStack {
                        Text(quote.symbol).font(.caption.monospaced().bold())
                        Spacer(minLength: 4)
                        Text(entry.isSample ? "—" : quote.last.formatted(.number.precision(.fractionLength(2))))
                            .font(.caption.monospaced())
                    }
                }
                if entry.isSample {
                    Text("Open DuoTrade to sync")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
