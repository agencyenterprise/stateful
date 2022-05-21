//
//  Lazy.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/19/22.
//

@propertyWrapper
struct Lazy<Value> {
    private var initializer: (() -> Value)?
    private var innerValue: Value?

    var projectedValue: Bool { innerValue == nil }

    var wrappedValue: Value {
        mutating get {
            if projectedValue {
                innerValue = initializer!()
                initializer = nil
            }

            return innerValue!
        }
    }

    init(wrappedValue: @escaping @autoclosure () -> Value) {
        self.initializer = wrappedValue
    }
}
