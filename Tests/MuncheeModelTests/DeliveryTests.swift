//
//  DeliveryTests.swift
//
//
//  Created by Lucas van Dongen on 01/11/2023.
//

import CoreLocation
import XCTest

@testable import MuncheeModel

@StateActor
final class DeliveryTests: XCTestCase {
    var order: Order!
    var delivery: Delivery!

    override func setUp() {
        order = Order(restaurant: Mocks.pizzaRestaurant)
        order.add(amount: 20, of: Mocks.pizzaEggplant)
        order.startPaying()
        order.paid()

        delivery = Delivery(order: order, estimatedDeliveryTime: Date())

        super.setUp()
    }

    func testOrderIllegalState() {
        let unpaidOrder = Order(restaurant: Mocks.pizzaRestaurant)

        XCTAssertNil(Delivery(order: unpaidOrder, estimatedDeliveryTime: Date()))
    }

    func testCancel() {
        XCTAssertTrue(delivery.cancel(reason: "Accidentally sent test Order to Live server"))
    }

    func testCancelImpossible() {
        XCTAssertTrue(delivery.startDelivery())
        XCTAssertTrue(delivery.delivered())
        XCTAssertFalse(delivery.cancel(reason: "Accidentally sent test Order to Live server"), "We cannot cancel a Delivered Order")
    }

    func testStartDeliveryImpossible() {
        XCTAssertTrue(delivery.startDelivery())
        XCTAssertTrue(delivery.delivered())
        XCTAssertFalse(delivery.startDelivery(), "Should not try to start delivery again")
    }

    func testUpdateCourier() {
        let newDate = Date().addingTimeInterval(6000)
        let newLocation = CLLocation(latitude: 12, longitude: 12)

        XCTAssertTrue(delivery.startDelivery())
        XCTAssertTrue(delivery.updateCourier(
            location: newLocation,
            estimatedDeliveryTime: newDate
        ))
        XCTAssertEqual(delivery.estimatedDeliveryTime, newDate)
        XCTAssertEqual(delivery.state, .underway(location: newLocation))
    }

    func testUpdateCourierFailed() {
        let newDate = Date().addingTimeInterval(6000)
        let newLocation = CLLocation(latitude: 12, longitude: 12)

        XCTAssertTrue(delivery.startDelivery())
        XCTAssertTrue(delivery.delivered())
        XCTAssertFalse(delivery.updateCourier(
            location: newLocation,
            estimatedDeliveryTime: newDate
        ))
        XCTAssertNotEqual(delivery.estimatedDeliveryTime, newDate)
        XCTAssertNotEqual(delivery.state, .underway(location: newLocation))
    }

    func testDeliveredTwice() {
        XCTAssertTrue(delivery.startDelivery())
        XCTAssertTrue(delivery.delivered())
        XCTAssertFalse(delivery.delivered(), "You cannot deliver twice")
    }

    func testDeliveredBeforeUnderway() {
        XCTAssertFalse(delivery.delivered(), "You cannot deliver what was not underway")
    }
}
