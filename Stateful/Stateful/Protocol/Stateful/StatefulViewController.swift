//
//  StatefulViewController.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/20/22.
//

import Combine
import UIKit

// MARK: - StatefulViewController

public protocol StatefulViewController: UIViewController {
    associatedtype ViewModel: StatefulViewModel
    associatedtype View: StatefulView where View.ContentView.Content == Content, View.Error == ViewModel.Error

    var viewModel: ViewModel { get }
    var stateView: View { get }
    var cancelables: Set<AnyCancellable> { get set }

    init(viewModel: ViewModel)

    func received(state: State)
    func received(errorWithContent error: ViewModel.Error)
}

public extension StatefulViewController {
    typealias ContentView = View.ContentView
    typealias Content = ViewModel.Content
    typealias Error = ViewModel.Error
    typealias State = StateMachine<Content, ViewModel.Error>
    typealias Result = State.Result

    var contentView: ContentView { stateView.contentView }
    var errorView: EmptyContentView { stateView.errorView }
    var loadingView: UIActivityIndicatorView { stateView.loadingView }

    /// Helper method to quickly setup the controller view hierarchy.
    func protocolLoadView() {
        stateView.apply { $0.translatesAutoresizingMaskIntoConstraints = false }
            .apply(view.addSubview)
            .let { [
                $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                $0.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ] }
            .let(NSLayoutConstraint.activate)

        stateView.onReload = { [weak self] in
            guard let self = self else { return }
            self.viewModel.reload()
        }

        cancelables.insert(viewModel.state.sink { [weak self] state in
            guard let self = self else { return }
            self.received(state: state)
        })

        viewModel.reload()
    }

    func received(state: State) {
        stateView.bind(content: state)
        if case let .error(error: error, content: _?) = state {
            self.received(errorWithContent: error)
        }
    }

    ///  Presents an alert with the error `localizedDescription` as the message.
    ///
    /// - Parameter error: Error received.
    ///
    /// Called when errors are received while having
    ///  past content `.error(error: someError, content: .some(_))`.
    func received(errorWithContent error: ViewModel.Error) {
        UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            .apply { $0.addAction(UIAlertAction(title: "OK", style: .cancel)) }
            .let { present($0, animated: true) }
    }
}
