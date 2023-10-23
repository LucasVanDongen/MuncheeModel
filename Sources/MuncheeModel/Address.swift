//
//  File.swift
//  
//
//  Created by Lucas van Dongen on 15/10/2023.
//

import Foundation

public struct Address {
    public let street: String
    public let number: String
    public let city: String
    public let zipCode: String
    public let country: String

    internal init(
        street: String,
        number: String,
        city: String,
        zipCode: String,
        country: String
    ) {
        self.street = street
        self.number = number
        self.city = city
        self.zipCode = zipCode
        self.country = country
    }
}

extension Address: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return
            lhs.number == rhs.number
            && lhs.zipCode == rhs.zipCode
            && lhs.country == rhs.country
    }
}
