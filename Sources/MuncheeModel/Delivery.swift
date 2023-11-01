//
//  Delivery.swift
//
//
//  Created by Lucas van Dongen on 21/10/2023.
//

import CoreLocation
import Foundation

@Observable
@StateActor
final public class Delivery {
    public enum State: Equatable {
        case waiting
        case cancelled(reason: String)
        case underway(location: CLLocation)
        case delivered
    }

    public let order: Order

    public private(set) var state: State = .waiting
    public private(set) var estimatedDeliveryTime: Date

    public init?(
        order: Order,
        estimatedDeliveryTime: Date
    ) {
        guard order.state == .paid else {
            return nil
        }

        self.order = order
        self.estimatedDeliveryTime = estimatedDeliveryTime
    }

    @discardableResult
    public func cancel(reason: String) -> Bool {
        if case .delivered = state {
            return false
        }

        state = .cancelled(reason: reason)
        return true
    }

    @discardableResult
    public func startDelivery() -> Bool {
        guard case .waiting = state else {
            return false
        }

        state = .underway(location: order.restaurant.location)
        return true
    }

    @discardableResult
    public func updateCourier(
        location: CLLocation,
        estimatedDeliveryTime: Date
    ) -> Bool {
        guard case .underway = state else {
            return false
        }

        state = .underway(location: location)
        self.estimatedDeliveryTime = estimatedDeliveryTime

        return true
    }

    @discardableResult
    public func delivered() -> Bool {
        guard case .underway = state else {
            return false
        }

        state = .delivered
        return true
    }
}
