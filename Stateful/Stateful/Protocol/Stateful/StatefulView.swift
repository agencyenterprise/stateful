//
//  StatefulView.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/20/22.
//

import UIKit

// MARK: - StatefulView

public protocol StatefulView: ContentBindable where Content == StateMachine<ContentView.Content, Error> {
    associatedtype ContentView: ContentBindable
    associatedtype Error: Swift.Error

    var contentView: ContentView { get }
    var errorView: EmptyContentView { get }
    var loadingView: UIActivityIndicatorView { get }

    var onReload: (() -> Void)? { get set }

    func bind(content: ContentView.Content)
    func bind(error: Error)
    func bindLoading()
}

public extension StatefulView {
    func bind(content state: Content) {
        if let content = state.content { bind(content: content) }
        else if state.isLoading { bindLoading() }
        else if let error = state.error { bind(error: error) }
    }

    func bind(content state: Content) where ContentView.Content: Emptiable {
        switch state {
        case .loading(content: nil): bindLoading()
        case let .error(error: error, content: nil): bind(error: error)
        case let .loading(content: content?) where content.isEmpty: bindLoading()
        case let .error(error: error, content: content?) where content.isEmpty: bind(error: error)
        case let .content(content: content),
             let .error(error: _, content: content?),
             let .loading(content: content?):
            bind(content: content)
        }
    }
}
