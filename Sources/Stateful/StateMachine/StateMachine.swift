//
//  StateMachine.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/19/22.
//

import Foundation

// MARK: - StateMachine

/// State machine that handles content, past content, and errors.
@frozen public enum StateMachine<Content, Error: Swift.Error> {
    case loading(content: Content?)
    case error(error: Error, content: Content?)
    case content(content: Content)

    public init(content: Content? = nil, error: Error? = nil) {
        if let error = error { self = .error(error: error, content: content) }
        else if let content = content { self = .content(content: content) }
        else { self = .loading(content: nil) }
    }
}

// MARK: - Unwrapped

public extension StateMachine {
    enum Case: CaseIterable, Hashable, Equatable {
        case loading
        case error
        case content
    }

    var content: Content? {
        switch self {
        case let .content(content), let .error(_, content?), let .loading(content?): return content
        case .error, .loading: return nil
        }
    }

    var error: Error? {
        switch self {
        case .content, .loading: return nil
        case let .error(error, _): return error
        }
    }

    var `case`: Case {
        switch self {
        case .loading: return .loading
        case .content: return .content
        case .error: return .error
        }
    }

    var isLoading: Bool { self.case == .loading }
    var isError: Bool { self.case == .error }
    var isContent: Bool { self.case == .content }

    func contentIfPresent(_ block: (_ content: Content) -> Void) { content.map(block) }
}

// MARK: Mapping

public extension StateMachine {
    func map<TransformedContent>(_ transform: (Content) -> TransformedContent) -> StateMachine<TransformedContent, Error> {
        let newState: StateMachine<TransformedContent, Error>
        switch self {
        case let .loading(content): newState = .loading(content: content.map(transform))
        case let .error(error, content): newState = .error(error: error, content: content.map(transform))
        case let .content(content): newState = .content(content: transform(content))
        }
        return newState
    }

    func compactMap<TransformedContent>(_ transform: (Content?) -> TransformedContent)
        -> StateMachine<TransformedContent, Error>
    {
        let newState: StateMachine<TransformedContent, Error>
        switch self {
        case let .loading(content): newState = .loading(content: transform(content))
        case let .error(error, content): newState = .error(error: error, content: transform(content))
        case let .content(content): newState = .content(content: transform(content))
        }
        return newState
    }

    func mapError<TransformedError>(_ transform: (Error) -> TransformedError) -> StateMachine<Content, TransformedError> {
        let newState: StateMachine<Content, TransformedError>
        switch self {
        case let .loading(content): newState = .loading(content: content)
        case let .error(error, content): newState = .error(error: transform(error), content: content)
        case let .content(content): newState = .content(content: content)
        }
        return newState
    }
}

// MARK: - Switch Mutating

public extension StateMachine {
    mutating func receivedLoading() { self = .loading(content: content) }
    mutating func received(content: Content) { self = .content(content: content) }
    mutating func received(error: Error) { self = .error(error: error, content: content) }

    /// Completely drops current data and restarts the StateMachine on empty loading.
    mutating func purgeContentAndError() { self = .loading(content: nil) }
}

// MARK: - Switch Non-mutating

public extension StateMachine {
    func receivingLoading() -> Self { .loading(content: content) }
    func receiving(content newContent: Content) -> Self { .content(content: newContent) }
    func receiving(error newError: Error) -> Self { .error(error: newError, content: content) }
    
    /// Completely drops current data and return a StateMachine on empty loading.
    func purgingContentAndError() -> Self { .loading(content: nil) }
}

// MARK: - StateMachine + Equatable

extension StateMachine: Equatable where Content: Equatable, Error: Equatable {}

// MARK: - StateMachine + Hashable

extension StateMachine: Hashable where Content: Hashable, Error: Hashable {}

// MARK: - StateMachine + Never

/// StateMachine that never fails.
public typealias SafeState<Content> = StateMachine<Content, Never>

public extension StateMachine where Content == Never {
    static var loading: Self { .loading(content: nil) }
    static func error(error: Error) -> Self { .error(error: error, content: nil) }
}

// MARK: - StateMachine + Result

public extension StateMachine where Error: Swift.Error {
    typealias Result = Swift.Result<Content, Error>
    init(result: Result) {
        switch result {
        case let .success(content): self.init(content: content, error: nil)
        case let .failure(error): self.init(content: nil, error: error)
        }
    }

    /// Helper method to bind a `Result`. Calls `received(content:)` on `success` and `received(error:)` on `failure`.
    ///
    /// - Parameter result: `Result` value being bound.
    mutating func received(result: Result) {
        switch result {
        case let .success(content): received(content: content)
        case let .failure(error): received(error: error)
        }
    }

    /// Helper method to bind a `Result`. Calls `receiving(content:)` on `success` and `receiving(error:)` on `failure`.
    ///
    /// - Parameter result: `Result` value being bound.
    func receiving(result: Result) -> Self {
        switch result {
        case let .success(content): return receiving(content: content)
        case let .failure(error): return receiving(error: error)
        }
    }
}

// MARK: - StateMachine + Decoding

public extension StateMachine where Content: Decodable {
    mutating func received(data: Data, mapError: (Swift.Error) -> Error) {
        do { self = .content(content: try JSONDecoder().decode(Content.self, from: data)) }
        catch { self = .error(error: mapError(error), content: content) }
    }

    func receiving(data: Data, mapError: (Swift.Error) -> Error) -> Self {
        do { return .content(content: try JSONDecoder().decode(Content.self, from: data)) }
        catch { return .error(error: mapError(error), content: content) }
    }
}

public extension StateMachine where Content: Decodable, Error == Swift.Error {
    mutating func received(data: Data) { received(data: data, mapError: { $0 }) }
    func receiving(data: Data) -> Self { receiving(data: data, mapError: { $0 }) }
}
