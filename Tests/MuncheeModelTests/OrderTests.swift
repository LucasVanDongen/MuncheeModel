import XCTest

@testable import MuncheeModel

@StateActor
final class OrderTests: XCTestCase {
    private var order: Order!

    override func setUp() {
        super.setUp()

        order = Order(restaurant: Mocks.sandwichRestaurant)
    }

    func testAddingProductToOrder() {
        let exp = expectation(description: "test")
        let expectedAmount = 2
        let expectedProduct = Mocks.hamSandwich

        print("Test body State \(Thread.current)")
        Task { @StateActor in
            XCTAssertTrue(order.add(amount: expectedAmount, of: expectedProduct))
            XCTAssertEqual(order.lines.count, 1)
            XCTAssertEqual(order.lines.last?.product, expectedProduct)
            XCTAssertEqual(order.lines.last?.amount, expectedAmount)

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func testAddingSameProductToOrder() {
        let firstAmount = 2
        let secondAmount = 1
        let expectedAmount = firstAmount + secondAmount
        XCTAssertTrue(order.add(amount: firstAmount, of: Mocks.hamSandwich))
        XCTAssertTrue(order.add(amount: secondAmount, of: Mocks.hamSandwich))
        XCTAssertEqual(order.lines.count, 1, "We should add it to the same orderLine, not duplicate the product")
        XCTAssertEqual(order.lines.last!.amount, expectedAmount, "We expect double the amount")
    }

    func testUpdatingOrderline() {
        let updatedAmount = 4
        XCTAssertTrue(order.add(amount: 2, of: Mocks.hamSandwich))
        XCTAssertTrue(order.update(amount: updatedAmount, of: Mocks.hamSandwich))
        XCTAssertEqual(order.lines.count, 1, "We should update the orderline, not duplicate the orderLine")
        XCTAssertEqual(order.lines.last!.amount, updatedAmount, "We expect the new amount")
    }

    func testFailToUpdateOrderline() {
        let updatedAmount = 4
        let expectedErrorStart = "Orderline for product"
        XCTAssertTrue(order.add(amount: 2, of: Mocks.hamSandwich))
        XCTAssertFalse(order.update(amount: updatedAmount, of: Mocks.cheeseSandwich))
        XCTAssertEqual(order.lines.count, 1, "We should not insert a new orderLine")
        XCTAssertEqual(order.lines.last!.product, Mocks.hamSandwich, "The product should not be changed")
        let beginOfLoggedError: String = String(order.logger.errors.first!.prefix(expectedErrorStart.count))
        XCTAssertEqual(beginOfLoggedError, expectedErrorStart)
    }

    func testDeleteOrderLine() {
        XCTAssertTrue(order.add(amount: 2, of: Mocks.hamSandwich))
        XCTAssertTrue(order.delete(product: Mocks.hamSandwich))
        XCTAssertEqual(order.lines.count, 0, "The line should be gone")
    }

    func testFailToDeleteOrderLine() {
        let expectedErrorStart = "Orderline for product"
        XCTAssertTrue(order.add(amount: 2, of: Mocks.hamSandwich))
        XCTAssertEqual(order.lines.count, 1, "Add should have worked")
        XCTAssertFalse(order.delete(product: Mocks.cheeseSandwich), "We cannot delete a product we didn't add")
        XCTAssertEqual(order.lines.count, 1, "We should not have removed the line")
        XCTAssertEqual(order.lines.last!.product, Mocks.hamSandwich, "The product should not be changed")
        let beginOfLoggedError: String = String(order.logger.errors.first!.prefix(expectedErrorStart.count))
        XCTAssertEqual(beginOfLoggedError, expectedErrorStart)
    }

    func testFailingToAddProductWhenOrderNotOpen() {
        startPaying()
        XCTAssertFalse(order.add(amount: 2, of: Mocks.cheeseSandwich))
    }

    func testFailingToUpdateProductWhenOrderNotOpen() {
        startPaying()
        XCTAssertFalse(order.update(amount: 2, of: Mocks.cheeseSandwich))
    }

    func testFailingToDeleteProductWhenOrderNotOpen() {
        startPaying()
        XCTAssertFalse(order.delete(product: Mocks.cheeseSandwich))
    }

    func testFailingToStartPayingOrderWhenNoProductsSelected() {
        XCTAssertFalse(order.startPaying())
        XCTAssertEqual(order.logger.errors.count, 1)
        XCTAssertEqual(order.logger.errors.first!, "You cannot start paying an order that has nothing in it")
        XCTAssertEqual(order.state, .open)
    }

    func testFailingToStartPayingWhenPayingAlreday() {
        startPaying()
        XCTAssertFalse(order.startPaying())
        XCTAssertEqual(order.logger.errors.count, 1)
        XCTAssertEqual(order.logger.errors.first!, "Cannot start paying order with state `.paying`, only `.open` orders")
        XCTAssertEqual(order.state, .paying)
    }

    func testNotPossibleToOrderFromDifferentRestaurants() {
        // We try to add a product that belongs to a different restaurant
        XCTAssertFalse(order.add(amount: 1, of: Mocks.pizzaRestaurant.products.first!))
        XCTAssertEqual(order.logger.errors.count, 1)
        XCTAssertEqual(order.lines.count, 0, "We should not be able to sell products not for the current restaurant")
        XCTAssertEqual(order.logger.errors.first!, "Trying to sell product not sold at restaurant")
    }

    func testNotPossibleToPayWhenMinimumOrderNotMet() {
        XCTAssertTrue(order.add(amount: 1, of: Mocks.hamSandwich))
        let sumOfOrder = order.lines.map { Decimal($0.amount) * $0.product.price }.reduce(0, +)
        XCTAssertGreaterThan(order.restaurant.minimumValueForDelivery, sumOfOrder)
        XCTAssertFalse(order.startPaying())
        XCTAssertEqual(order.state, .open)
        XCTAssertEqual(order.logger.errors.first!, "You cannot have your food delivered when you did not order the minimum amount")
    }

    func testWhenNotOrderingEnoughMinimumOrderMetIsFalse() {
        XCTAssertTrue(order.add(amount: 1, of: Mocks.hamSandwich))
        XCTAssertFalse(order.minimumOrderMet)
    }

    func testWhenOrderingTheMinimumMinimumOrderMetIsTrue() {
        XCTAssertTrue(order.add(amount: 100, of: Mocks.hamSandwich))
        XCTAssertTrue(order.minimumOrderMet)
    }

    func testWhenEditingTheOrderBackBelowTheMinimumMinimumOrderMetIsFalseAgain() {
        XCTAssertTrue(order.add(amount: 100, of: Mocks.hamSandwich))
        XCTAssertTrue(order.minimumOrderMet)
        XCTAssertTrue(order.update(amount: 1, of: Mocks.hamSandwich))
        XCTAssertEqual(order.lines.first!.amount, 1)
        XCTAssertFalse(order.minimumOrderMet)
    }

    func testSetPaid() {
        startPaying()
        XCTAssertTrue(order.paid())
    }

    func testFailToSetPaid() {
        XCTAssertFalse(order.paid(), "You cannot set `.paid` before going into `.paying`")
    }

    func testOrderEquality() {
        let otherRestaurantOrder = Order(restaurant: Mocks.pizzaRestaurant)
        let sameRestaurantOrder = Order(restaurant: Mocks.sandwichRestaurant)

        XCTAssertEqual(order, sameRestaurantOrder)
        XCTAssertNotEqual(order, otherRestaurantOrder)
    }

    func testOrderHashability() {
        var hasher = Hasher()
        order.hash(into: &hasher)
        XCTAssertNotEqual(hasher.finalize(), 0)
    }

    private func startPaying() {
        XCTAssertTrue(order.add(amount: 10, of: Mocks.hamSandwich))
        let sumOfOrder = order.lines.map { Decimal($0.amount) * $0.product.price }.reduce(0, +)
        XCTAssertLessThan(order.restaurant.minimumValueForDelivery, sumOfOrder)
        XCTAssertTrue(order.startPaying())
        XCTAssertEqual(order.state, .paying)
    }
}
