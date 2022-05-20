//
//  Scope.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/19/22.
//

import Foundation

// MARK: - Scope

internal protocol Scope {}

internal extension Scope {
    @inlinable
    @inline(__always)
    func `let`<Tranformed>(_ block: (Self) throws -> Tranformed) rethrows -> Tranformed { try block(self) }
}

internal extension Scope where Self: AnyObject {
    @inlinable
    @inline(__always)
    func apply(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
}

// MARK: - NSObject + Scope

extension NSObject: Scope {}

// MARK: - Array + Scope

extension Array: Scope {}
