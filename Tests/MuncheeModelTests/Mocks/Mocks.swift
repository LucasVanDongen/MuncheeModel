//
//  Mocks.swift
//
//
//  Created by Lucas van Dongen on 16/10/2023.
//

import Foundation

@testable import MuncheeModel
import CoreLocation

class Mocks {
    static let address1 = Address(
        street: "Street",
        number: "1",
        city: "City",
        zipCode: "90210",
        country: "Codonia"
    )
    static let address2 = Address(
        street: "Street",
        number: "2",
        city: "City",
        zipCode: "909808",
        country: "Codonia"
    )
    static let sandwichRestaurant = Restaurant(
        id: "1",
        name: "The Sandwich Lord",
        address: address1, 
        location: CLLocation(latitude: 0, longitude: 0),
        products: [hamSandwich, cheeseSandwich],
        minimumValueForDelivery: 12.5
    )
    static let hamSandwich = Product(
        id: "1",
        name: "Ham Sandwich",
        price: 1.30
    )
    static let cheeseSandwich = Product(
        id: "2",
        name: "Cheese sandwich",
        price: 1.15
    )
    static let pizzaRestaurant = Restaurant(
        id: "2",
        name: "Dan's Deep Pan Pizza Parlor",
        address: address1,
        location: CLLocation(latitude: 0, longitude: 0),
        products: [pizzaPepperoni, pizzaEggplant],
        minimumValueForDelivery: 12.5
    )
    static let pizzaPepperoni = Product(
        id: "3",
        name: "Pepperoni Pizza",
        price: 13.5
    )
    static let pizzaEggplant = Product(
        id: "4",
        name: "Eggplant Pizza",
        price: 12.75
    )
    @StateActor static let order = Order(restaurant: pizzaRestaurant)
}
