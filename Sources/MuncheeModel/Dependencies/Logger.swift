//
//  Logger.swift
//
//
//  Created by Lucas van Dongen on 16/10/2023.
//

import Foundation

protocol Logging {
    var errors: [String] { get }

    func log(error: String)
}

class Logger: Logging {
    private(set) var errors: [String] = []

    func log(error: String) {
        errors.append(error)
    }
}
