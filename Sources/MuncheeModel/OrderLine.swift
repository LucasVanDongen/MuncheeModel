//
//  OrderLine.swift
//  
//
//  Created by Lucas van Dongen on 16/10/2023.
//

import Foundation

public class OrderLine: Equatable {
    public let product: Product
    public private(set) var amount: Int

    init(
        product: Product,
        amount: Int
    ) {
        self.product = product
        self.amount = amount
    }

    func update(amount: Int) {
        self.amount = amount
    }

    public static func == (lhs: OrderLine, rhs: OrderLine) -> Bool {
        return lhs.product == rhs.product
    }
}
