import Testing
@testable import ChartEngine

@Suite("Chart style")
struct ChartStyleTests {
    @Test func allStylesRoundTripThroughRawValue() {
        for style in ChartStyle.allCases {
            #expect(ChartStyle(rawValue: style.rawValue) == style)
        }
    }
}
