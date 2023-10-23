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

public class Order {
    @Published public private(set) var state: OrderState = .open
    @Published public private(set) var lines = [OrderLine]()
    @Published public private(set) var minimumOrderMet = false
    @Published public private(set) var address: AddressState = .none

    public let restaurant: Restaurant

    let logger: Logging = Logger()

    var canEditOrder: Bool {
        return state == .open
    }

    private var cancelBag = Set<AnyCancellable>()

    init(restaurant: Restaurant) {
        self.restaurant = restaurant

        startObservingOrderLines()
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

        let existingLine = lines.first(where: {
            $0.product.id == product.id
        })

        switch existingLine {
        case let .some(existingLine):
            let newTotal = existingLine.amount + amount
            existingLine.update(amount: newTotal)
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

        guard let orderLine = lines.first(where: {
            $0.product.id == product.id
        }) else {
            logger.log(error: "Orderline for product \(product.name) with id \(product.id) does not exist")
            return false
        }

        orderLine.update(amount: newAmount)

        return true
    }

    @discardableResult
    func delete(product: Product) -> Bool {
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

    private func startObservingOrderLines() {
        $lines.sink { [unowned self] updatedLines in
            let sumOfOrder = updatedLines.map { Decimal($0.amount) * $0.product.price }.reduce(0, +)
            self.minimumOrderMet = sumOfOrder >= restaurant.minimumValueForDelivery
        }.store(in: &cancelBag)
    }
}
