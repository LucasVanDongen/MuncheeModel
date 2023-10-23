//
//  Product.swift
//
//
//  Created by Lucas van Dongen on 16/10/2023.
//

import Foundation

public struct Product: Equatable {
    public let id: String
    public let name: String
    public let price: Decimal

    public init(
        id: String,
        name: String,
        price: Decimal
    ) {
        self.id = id
        self.name = name
        self.price = price
    }
}
