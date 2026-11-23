import SwiftUI
import WidgetKit

/// Widget extension entry point. Live Activities / Dynamic Island join in Phase 7.
@main
struct DuoTradeWidgetsBundle: WidgetBundle {
    var body: some Widget {
        WatchlistGlanceWidget()
    }
}
