//
//  ModelTests.swift
//
//
//  Created by Lucas van Dongen on 16/10/2023.
//

import XCTest

@testable import MuncheeModel

final class ModelTests: XCTestCase {
    private var model: Model!

    override func setUp() {
        super.setUp()

        model = Model()
    }

    func testWhenTheRestaurantChangesOrderIsReset() {
        self.model.select(restaurant: Mocks.sandwichRestaurant)
        XCTAssertEqual(self.model.selectedRestaurant, Mocks.sandwichRestaurant)

        // We place one item in the order so we can track it's reset later
        self.model.order!.add(amount: 1, of: Mocks.sandwichRestaurant.products.first!)
        XCTAssertEqual(self.model.order!.lines.count, 1)

        // Now we switch to a different restaurant
        self.model.select(restaurant: Mocks.pizzaRestaurant)
        XCTAssertEqual(self.model.selectedRestaurant, Mocks.pizzaRestaurant)

        // And the lines are gone
        XCTAssertEqual(self.model.order!.lines.count, 0)
    }

    func testWhenTheRestaurantChangesToSameOrderIsNotReset() {
        self.model.select(restaurant: Mocks.sandwichRestaurant)
        XCTAssertEqual(self.model.selectedRestaurant, Mocks.sandwichRestaurant)

        // We place one item in the order so we can track it's reset later
        self.model.order!.add(amount: 1, of: Mocks.sandwichRestaurant.products.first!)
        XCTAssertEqual(self.model.order!.lines.count, 1)

        // You selected the same restaurant
        self.model.select(restaurant: Mocks.sandwichRestaurant)
        XCTAssertEqual(self.model.selectedRestaurant, Mocks.sandwichRestaurant)

        // And we assume you wanted to keep your items
        XCTAssertEqual(self.model.order!.lines.count, 1)
    }
}
