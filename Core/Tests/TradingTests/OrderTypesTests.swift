import Testing
@testable import Trading

@Suite("Order types")
struct OrderTypesTests {
    @Test func sideSignAndOpposite() {
        #expect(OrderSide.buy.sign == 1)
        #expect(OrderSide.sell.sign == -1)
        #expect(OrderSide.buy.opposite == .sell)
    }
}
