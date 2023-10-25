//
//  OrderLine.swift
//  
//
//  Created by Lucas van Dongen on 16/10/2023.
//

import Foundation

@Observable
public class OrderLine: Equatable {
    public let product: Product
    public private(set) var amount: Int

    public var total: Decimal {
        Decimal(amount) * product.price
    }

    public init(
        product: Product,
        amount: Int
    ) {
        self.product = product
        self.amount = amount
    }

    public func update(amount: Int) {
        self.amount = amount
    }

    public static func == (lhs: OrderLine, rhs: OrderLine) -> Bool {
        return lhs.product == rhs.product
    }
}
