//
//  Emptiable.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/19/22.
//

// MARK: - Emptiable

/// A type that can be empty.
public protocol Emptiable {
    /// Empty representation of the type.
    static var empty: Self { get }
    
    /// Is the value empty.
    var isEmpty: Bool { get }
}
