//
//  Emptiable.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/19/22.
//

// MARK: - Emptiable

public protocol Emptiable {
    static var empty: Self { get }
    var isEmpty: Bool { get }
}

// MARK: - Emptiable + Equatable

public extension Emptiable where Self: Equatable {
    var isEmpty: Bool { self == .empty }
}
