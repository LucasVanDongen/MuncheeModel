//
//  StateActor.swift
//
//
//  Created by Lucas van Dongen on 31/10/2023.
//

import Foundation

@globalActor
public struct StateActor {
    public actor ActorType { }

    public static let shared: ActorType = ActorType()
}
