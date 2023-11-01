//
//  AddressTests.swift
//  
//
//  Created by Lucas van Dongen on 01/11/2023.
//

import XCTest

@testable import MuncheeModel

final class AddressTests: XCTestCase {
    static let street = "Street"
    static let number = "123a"
    static let city = "City"
    static let zipCode = "90210"
    static let country = "Country"

    lazy var address = Address(
        street: Self.street,
        number: Self.number,
        city: Self.city,
        zipCode: Self.zipCode,
        country: Self.country
    )
    lazy var differentNumber = Address(
        street: Self.street,
        number: "321b",
        city: Self.city,
        zipCode: Self.zipCode,
        country: Self.country
    )
    lazy var differentZipCode = Address(
        street: Self.street,
        number: Self.number,
        city: Self.city,
        zipCode: "00000",
        country: Self.country
    )
    lazy var differentCountry = Address(
        street: Self.street,
        number: Self.number,
        city: Self.city,
        zipCode: Self.zipCode,
        country: "Different"
    )
    lazy var differentStreet = Address(
        street: "Road",
        number: Self.number,
        city: Self.city,
        zipCode: Self.zipCode,
        country: Self.country
    )
    lazy var differentCity = Address(
        street: Self.street,
        number: Self.number,
        city: "Town",
        zipCode: Self.zipCode,
        country: Self.country
    )

    func testEquality() {
        XCTAssertNotEqual(address, differentZipCode)
        XCTAssertNotEqual(address, differentCountry)
        XCTAssertNotEqual(address, differentNumber)
        XCTAssertEqual(address, differentCity)
        XCTAssertEqual(address, differentStreet)
    }
}
