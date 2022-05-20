//
//  StateView.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/19/22.
//

import UIKit

// MARK: - StateView

open class StateView<ContentView: ContentBindable, Error: Swift.Error>: UIView {
    @Lazy public var contentView = ContentView().apply {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    @Lazy public var errorView = EmptyContentView().apply {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    @Lazy public var loadingView = UIActivityIndicatorView(style: .medium).apply {
        $0.hidesWhenStopped = true
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    fileprivate lazy var reloadGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(__reloadSelector)
    )

    public var onReload: (() -> Void)?

    public init(state: Content = .loading(content: nil)) {
        super.init(frame: .zero)
        bind(content: state)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func __reloadSelector() { onReload?() }

    open func addAndConstraintLoadingView() {
        loadingView.apply(addSubview)
            .let { [
                $0.centerXAnchor.constraint(equalTo: centerXAnchor),
                $0.centerYAnchor.constraint(equalTo: centerYAnchor),
            ] }
            .let(NSLayoutConstraint.activate)
    }

    open func addAndConstraintErrorView() {
        errorView.apply(addSubview)
            .let { [
                $0.centerXAnchor.constraint(equalTo: centerXAnchor),
                $0.centerYAnchor.constraint(equalTo: centerYAnchor),
                $0.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
                $0.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
                $0.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
                $0.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor)
            ] }
            .let(NSLayoutConstraint.activate)
    }

    open func addAndConstraintContentView() {
        contentView.apply(addSubview)
            .let { [
                $0.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                $0.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
            ] }
            .let(NSLayoutConstraint.activate)
    }

    open func bind(content: ContentView.Content) {
        if !$loadingView { loadingView.stopAnimating() }
        if !$errorView { errorView.isHidden = true }
        if $contentView { addAndConstraintContentView() }

        contentView.isHidden = false
        contentView.bind(content: content)
    }

    open func bind(error: Error) {
        if !$loadingView { loadingView.stopAnimating() }
        if !$contentView { contentView.isHidden = true }
        if $errorView {
            addAndConstraintErrorView()
            errorView.addGestureRecognizer(reloadGestureRecognizer)
        }

        errorView.isHidden = false
        errorView.bind(icon: UIImage(systemName: "exclamationmark.square"), error: error)
    }

    open func bindLoading() {
        if !$errorView { errorView.isHidden = true }
        if !$contentView { contentView.isHidden = true }
        if $loadingView { addAndConstraintLoadingView() }

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
            if !$loadingView { loadingView.stopAnimating() }
            if !$contentView { contentView.isHidden = true }
            if $errorView {
                addAndConstraintErrorView()
                errorView.addGestureRecognizer(reloadGestureRecognizer)
            }

            errorView.isHidden = false
            errorView.bind(content: emptyContentMessage)
        } else {
            super.bind(content: content)
        }
    }
}
