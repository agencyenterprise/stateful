//
//  ViewController.swift
//  StatefulExample
//
//  Created by Lucas Assis Rodrigues on 5/20/22.
//

import Combine
import Stateful
import UIKit

typealias Content = [Int]

// MARK: - View

final class View: UIStackView, ContentBindable {
    var numbers: Content = [] {
        didSet {
            arrangedSubviews.forEach { $0.removeFromSuperview() }
            numbers.map {
                let label = UILabel()
                label.text = "\($0)"
                label.setContentHuggingPriority(.required, for: .vertical)
                return label
            }
            .forEach(addArrangedSubview)
        }
    }

    func bind(content: Content) { numbers = content }
}

// MARK: - ViewModel

final class ViewModel: StatefulViewModel {
    enum Error: Swift.Error, LocalizedError {
        case example
        var errorDescription: String? { "This is an error example." }
    }

    var state = CurrentValueSubject<StateMachine<Content, Error>, Never>()

    var workItem: DispatchWorkItem? {
        willSet { workItem?.cancel() }
    }

    func loadContent(_ completion: @escaping (Result<Content, Error>) -> Void) {
        workItem = .init {
            switch (0 ... 100).randomElement()! {
            case let i where (0 ... 75).contains(i):
                completion(.success(Bool.random() ? [] : [1, 2, 3, 4, 5]))
            default:
                completion(.failure(.example))
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: workItem!)
    }

    func purge() { state.purge() }
}

// MARK: - ViewController

final class ViewController: EmptiableStateViewController<ScrollView, ViewModel> {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Numbers"
        emptyContentMessage = .init(icon: UIImage(systemName: "doc.fill"), message: "No numbers loaded.")
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Purge", style: .plain, target: self, action: #selector(purge)),
            UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reload))
        ]
        reload()
    }

    @objc func purge() { viewModel.purge() }
    @objc func reload() { viewModel.reload() }

    override func received(state: EmptiableStateViewController<ScrollView, ViewModel>.State) {
        super.received(state: state)
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = !state.isLoading }
        if state.isLoading, ![nil, true].contains(state.content?.isEmpty) {
            let loading = UIActivityIndicatorView()
            loading.startAnimating()
            navigationItem.titleView = loading
        } else {
            navigationItem.titleView = nil
        }
    }
}
