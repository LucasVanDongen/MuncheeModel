//
//  OrderLineTests.swift
//  
//
//  Created by Lucas van Dongen on 01/11/2023.
//

import XCTest

@testable import MuncheeModel

@StateActor
final class OrderLineTests: XCTestCase {
    private let orderLineProduct1 = OrderLine(product: Mocks.pizzaPepperoni, amount: 10)
    private let orderLineProduct1Again = OrderLine(product: Mocks.pizzaPepperoni, amount: 1)
    private let orderLineProduct2 = OrderLine(product: Mocks.hamSandwich, amount: 10)

    func testEquality() {
        XCTAssertEqual(orderLineProduct1, orderLineProduct1Again)
        XCTAssertNotEqual(orderLineProduct1, orderLineProduct2)
    }
}
