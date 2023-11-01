//
//  Model.swift
//
//
//  Created by Lucas van Dongen on 16/10/2023.
//

import Foundation
import Combine

@Observable
@StateActor
final public class Model {
    public private(set) var selectedRestaurant: Restaurant? {
        didSet(previousRestaurant) {
            replaceOrder(
                whenPreviousRestaurant: previousRestaurant,
                wasNotTheSameAs: selectedRestaurant
            )
        }
    }
    public private(set) var order: Order?

    private var cancelBag = Set<AnyCancellable>()

    public init() { }

    public func select(restaurant: Restaurant) {
        selectedRestaurant = restaurant
    }

    @discardableResult
    func replaceOrder(
        whenPreviousRestaurant previousRestaurant: Restaurant?,
        wasNotTheSameAs newRestaurant: Restaurant?
    ) -> Bool {
        guard newRestaurant != previousRestaurant else {
            return false
        }

        switch newRestaurant {
        case let .some(restaurant):
            self.order = Order(restaurant: restaurant)
        case .none:
            self.order = nil
        }

        return true
    }
}
