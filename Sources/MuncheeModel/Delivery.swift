//
//  Delivery.swift
//
//
//  Created by Lucas van Dongen on 21/10/2023.
//

import CoreLocation
import Foundation

public class Delivery {
    public enum State {
        case waiting
        case cancelled(reason: String)
        case underway(location: CLLocation)
        case delivered
    }

    public let order: Order

    @Published public private(set) var state: State = .waiting
    @Published public private(set) var estimatedDeliveryTime: Date

    var isEditable: Bool {
        switch state {
        case .underway, .waiting:
            return true
        case .delivered, .cancelled:
            return false
        }
    }

    public init(
        order: Order,
        estimatedDeliveryTime: Date
    ) {
        self.order = order
        self.estimatedDeliveryTime = estimatedDeliveryTime
    }

    public func cancel(reason: String) {
        state = .cancelled(reason: reason)
    }

    public func startDelivery() {
        state = .underway(location: order.restaurant.location)
    }

    public func update(location: CLLocation) {
        state = .underway(location: location)
    }

    public func update(estimatedDeliveryTime: Date) {
        self.estimatedDeliveryTime = estimatedDeliveryTime
    }
}
