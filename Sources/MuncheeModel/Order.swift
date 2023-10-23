//
//  Order.swift
//
//
//  Created by Lucas van Dongen on 15/10/2023.
//

import Combine
import Foundation

public enum OrderState {
    case open
    case paying
    case delivering
    case delivered
}

public enum AddressState {
    case none
    case remembered(address: Address)
    case user(address: Address)
    case confirmed(address: Address)
}

@Observable public class Order {
    public private(set) var state: OrderState = .open
    public private(set) var lines = [OrderLine]() {
        didSet {
            updateTotal()
        }
    }
    public private(set) var minimumOrderMet = false
    public private(set) var address: AddressState = .none

    public let restaurant: Restaurant

    let logger: Logging = Logger()

    var canEditOrder: Bool {
        return state == .open
    }

    private var cancelBag = Set<AnyCancellable>()

    public init(restaurant: Restaurant) {
        self.restaurant = restaurant
    }

    @discardableResult
    public func add(
        amount: Int,
        of product: Product
    ) -> Bool {
        guard canEditOrder else {
            logger.log(error: "Cannot add orderline when order is not open")
            return false
        }

        guard restaurant.sells(product: product) else {
            logger.log(error: "Trying to sell product not sold at restaurant")
            return false
        }

        let existingLineIndex = lines.firstIndex(where: {
            $0.product.id == product.id
        })

        switch existingLineIndex {
        case let .some(existingLineIndex):
            let newTotal = lines[existingLineIndex].amount + amount
            lines[existingLineIndex].update(amount: newTotal)
        case .none:
            let newLine = OrderLine(
                product: product,
                amount: amount
            )
            lines.append(newLine)
        }

        return true
    }

    @discardableResult
    public func update(
        amount newAmount: Int,
        of product: Product
    ) -> Bool {
        guard canEditOrder else {
            logger.log(error: "Cannot update orderline when order is not open")
            return false
        }

        guard let orderLineIndex = lines.firstIndex(where: {
            $0.product.id == product.id
        }) else {
            logger.log(error: "Orderline for product \(product.name) with id \(product.id) does not exist")
            return false
        }

        lines[orderLineIndex].update(amount: newAmount)

        return true
    }

    @discardableResult
    public func delete(product: Product) -> Bool {
        guard canEditOrder else {
            logger.log(error: "Cannot delete orderline when order is not open")
            return false
        }

        guard let indexToDelete = lines.firstIndex(where: {
            $0.product.id == product.id
        }) else {
            logger.log(error: "Orderline for product \(product.name) with id \(product.id) does not exist")
            return false
        }

        lines.remove(at: indexToDelete)

        return true
    }

    @discardableResult
    public func startPaying() -> Bool {
        guard state == .open else {
            logger.log(error: "Cannot start paying order with state `.\(state)`, only `.open` orders")
            return false
        }

        guard !lines.isEmpty else {
            logger.log(error: "You cannot start paying an order that has nothing in it")
            return false
        }

        guard minimumOrderMet else {
            logger.log(error: "You cannot have your food delivered when you did not order the minimum amount")
            return false
        }

        state = .paying

        return true
    }

    func updateTotal() {
        let sumOfOrder = lines.map { Decimal($0.amount) * $0.product.price }.reduce(0, +)
        minimumOrderMet = sumOfOrder >= restaurant.minimumValueForDelivery
    }
}
