//
//  Restaurant.swift
//
//
//  Created by Lucas van Dongen on 16/10/2023.
//

import CoreLocation

public struct Restaurant {
    public let id: String
    public let name: String
    public let address: Address
    public let location: CLLocation
    public let products: [Product]
    public let minimumValueForDelivery: Decimal
}

extension Restaurant: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Restaurant {
    func sells(product: Product) -> Bool {
        return products.contains(product)
    }
}
