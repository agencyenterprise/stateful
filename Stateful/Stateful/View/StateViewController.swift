//
//  StateViewController.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/19/22.
//

import Combine
import UIKit

// MARK: - StateViewController

open class StateViewController<
    ContentView: ContentBindable,
    ViewModel: StatefulViewModel
>: UIViewController, StatefulViewController where ContentView.Content == ViewModel.Content {
    public typealias View = StateView<ContentView, ViewModel.Error>

    public let viewModel: ViewModel
    public var cancelables: Set<AnyCancellable> = []

    public private(set) lazy var stateView = View()

    public required init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override open func loadView() {
        super.loadView()
        protocolLoadView()
    }
}

// MARK: - EmptiableStateViewController

open class EmptiableStateViewController<
    ContentView: ContentBindable,
    ViewModel: StatefulViewModel
>: UIViewController, StatefulViewController where ContentView.Content == ViewModel.Content, ContentView.Content: Emptiable {
    public typealias View = EmptiableStateView<ContentView, ViewModel.Error>

    public let viewModel: ViewModel
    public var cancelables: Set<AnyCancellable> = []

    public var emptyContentMessage: EmptyContentView.Content {
        get { stateView.emptyContentMessage }
        set { stateView.emptyContentMessage = newValue }
    }

    public private(set) lazy var stateView = View()

    public required init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override open func loadView() {
        super.loadView()
        protocolLoadView()
    }

    public func received(state: State) {
        stateView.bind(content: state)
        if case let .error(error: error, content: content?) = state, !content.isEmpty {
            self.received(errorWithContent: error)
        }
    }
}
