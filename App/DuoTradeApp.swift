import SwiftUI

/// DuoTrade entry point.
///
/// Uses the SwiftUI `App` / `WindowGroup` scene lifecycle exclusively (backed by
/// `UIScene`; see `UIApplicationSceneManifest` in `Config/DuoTrade-Info.plist`).
/// All durable state lives in `AppModel`, created once here and injected into a
/// single adaptive view hierarchy, so fold / unfold transitions never reset it.
@main
struct DuoTradeApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            WorkspaceRootView()
                .environment(model)
                .onOpenURL { url in
                    model.handle(url: url)
                }
        }
    }
}
