//
//  StateView.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/19/22.
//

import UIKit

// MARK: - StateView

open class StateView<ContentView: ContentBindable, Error: Swift.Error>: UIView {
    public let contentView = ContentView()
    public let errorView = EmptyContentView()
    public let loadingView = UIActivityIndicatorView(style: .medium)

    public var onReload: (() -> Void)?

    public init(state: Content = .loading(content: nil)) {
        super.init(frame: .zero)

        loadingView.apply {
            $0.hidesWhenStopped = true
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        .apply(addSubview)
        .let { [
            $0.centerXAnchor.constraint(equalTo: centerXAnchor),
            $0.centerYAnchor.constraint(equalTo: centerYAnchor),
        ] }
        .let(NSLayoutConstraint.activate)

        errorView.apply {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(__reloadSelector)))
        }
        .apply(addSubview)
        .let { [
            $0.centerXAnchor.constraint(equalTo: centerXAnchor),
            $0.centerYAnchor.constraint(equalTo: centerYAnchor),
            $0.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            $0.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
            $0.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
            $0.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor)
        ] }
        .let(NSLayoutConstraint.activate)

        contentView.apply { $0.translatesAutoresizingMaskIntoConstraints = false }
            .apply(addSubview)
            .let { [
                $0.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                $0.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
            ] }
            .let(NSLayoutConstraint.activate)

        bind(content: state)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func __reloadSelector() { onReload?() }

    open func bind(content: ContentView.Content) {
        loadingView.stopAnimating()
        errorView.isHidden = true
        contentView.isHidden = false
        contentView.bind(content: content)
    }

    open func bind(error: Error) {
        loadingView.stopAnimating()
        contentView.isHidden = true
        errorView.isHidden = false
        errorView.bind(icon: UIImage(systemName: "exclamationmark.square"), error: error)
    }

    open func bindLoading() {
        errorView.isHidden = true
        contentView.isHidden = true
        loadingView.startAnimating()
    }
}

// MARK: - StateView + StatefulView

extension StateView: StatefulView {
    public typealias Content = StateMachine<ContentView.Content, Error>
}

// MARK: - SafeStateView

open class SafeStateView<ContentView: ContentBindable>: StateView<ContentView, Never> {}

// MARK: - EmptiableStateView

open class EmptiableStateView<
    ContentView: ContentBindable,
    Error: Swift.Error
>: StateView<ContentView, Error> where ContentView.Content: Emptiable {
    var emptyContentMessage = EmptyContentView.Content.empty

    override public func bind(content: ContentView.Content) {
        if content.isEmpty, !emptyContentMessage.isEmpty {
            loadingView.stopAnimating()
            contentView.isHidden = true
            errorView.isHidden = false
            errorView.bind(content: emptyContentMessage)
        } else {
            super.bind(content: content)
        }
    }
}
