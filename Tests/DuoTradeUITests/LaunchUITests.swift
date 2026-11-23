import XCTest

final class LaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsTradeWorkspace() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["workspace.symbol"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts["workspace.symbol"].label, "BTC-USD")
    }

    @MainActor
    func testStateSurvivesRotationResize() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["workspace.symbol"].waitForExistence(timeout: 10))

        // Rotation forces a full resize transition of the single view hierarchy.
        // (Folds are exercised manually in Device Hub; see CLAUDE.md.)
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertEqual(app.staticTexts["workspace.timeframe"].label, "5m")
        XCUIDevice.shared.orientation = .portrait
        XCTAssertEqual(app.staticTexts["workspace.symbol"].label, "BTC-USD")
    }
}
