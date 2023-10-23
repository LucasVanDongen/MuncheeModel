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
}

extension Address: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return
            lhs.number == rhs.number
            && lhs.zipCode == rhs.zipCode
            && lhs.country == rhs.country
    }
}
