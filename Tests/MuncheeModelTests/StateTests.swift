//
//  StateTests.swift
//  
//
//  Created by Lucas van Dongen on 16/10/2023.
//

import XCTest

@testable import MuncheeModel

final class StateTests: XCTestCase {
    private var state: State!

    override func setUp() {
        super.setUp()

        state = State()
    }

    func testWhenTheRestaurantChangesOrderIsReset() {
        self.state.select(restaurant: Mocks.sandwichRestaurant)
        XCTAssertEqual(self.state.selectedRestaurant, Mocks.sandwichRestaurant)

        // We place one item in the order so we can track it's reset later
        self.state.order!.add(amount: 1, of: Mocks.sandwichRestaurant.products.first!)
        XCTAssertEqual(self.state.order!.lines.count, 1)

        // Now we switch to a different restaurant
        self.state.select(restaurant: Mocks.pizzaRestaurant)
        XCTAssertEqual(self.state.selectedRestaurant, Mocks.pizzaRestaurant)

        // And the lines are gone
        XCTAssertEqual(self.state.order!.lines.count, 0)
    }

    func testWhenTheRestaurantChangesToSameOrderIsNotReset() {
        self.state.select(restaurant: Mocks.sandwichRestaurant)
        XCTAssertEqual(self.state.selectedRestaurant, Mocks.sandwichRestaurant)

        // We place one item in the order so we can track it's reset later
        self.state.order!.add(amount: 1, of: Mocks.sandwichRestaurant.products.first!)
        XCTAssertEqual(self.state.order!.lines.count, 1)

        // You selected the same restaurant
        self.state.select(restaurant: Mocks.sandwichRestaurant)
        XCTAssertEqual(self.state.selectedRestaurant, Mocks.sandwichRestaurant)

        // And we assume you wanted to keep your items
        XCTAssertEqual(self.state.order!.lines.count, 1)
    }
}
