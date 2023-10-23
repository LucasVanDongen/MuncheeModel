//
//  State.swift
//
//
//  Created by Lucas van Dongen on 16/10/2023.
//

import Foundation
import Combine

public let state = State()

public class State {
    @Published public private(set) var user: User?
    @Published public private(set) var selectedRestaurant: Restaurant?
    @Published public private(set) var order: Order?

    private var cancelBag = Set<AnyCancellable>()

    init() {
        startObservingSelectedRestaurant()
    }

    public func select(restaurant: Restaurant) {
        selectedRestaurant = restaurant
    }

    private func startObservingSelectedRestaurant() {
        $selectedRestaurant.scan(Restaurant?.none) { [unowned self] previousRestaurant, newRestaurant in
            if newRestaurant != previousRestaurant {
                if let newRestaurant {
                    self.order = Order(restaurant: newRestaurant)
                }
            }

            return newRestaurant
        }.sink { _ in }.store(in: &cancelBag)
    }
}
