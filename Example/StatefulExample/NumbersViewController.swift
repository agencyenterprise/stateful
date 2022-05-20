//
//  NumbersViewController.swift
//  StatefulExample
//
//  Created by Lucas Assis Rodrigues on 5/20/22.
//

import Combine
import Stateful
import UIKit

// MARK: - NumbersView

final class NumbersView: UIStackView, ContentBindable {
    var numbers: [Int] = [] {
        didSet {
            arrangedSubviews.forEach { $0.removeFromSuperview() }
            numbers.map {
                let label = UILabel()
                label.text = "\($0)"
                return label
            }
            .forEach(addArrangedSubview)
        }
    }

    func bind(content: [Int]) { numbers = content }
}

// MARK: - Array + Emptiable

extension Array: Emptiable {
    public static var empty: Self { [] }
}

// MARK: - NumbersViewModel

final class NumbersViewModel: StatefulViewModel {
    enum Error: Swift.Error, LocalizedError {
        case example
        var errorDescription: String? { "This is an error example." }
    }

    var state = CurrentValueSubject<StateMachine<[Int], Error>, Never>()

    func loadContent(_ completion: @escaping (Result<[Int], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds((0 ... 3).randomElement()!)) {
            switch (0 ... 100).randomElement()! {
            case let i where (0 ... 50).contains(i):
                completion(.success(Bool.random() ? [] : Array(0 ... i)))
            default:
                completion(.failure(.example))
            }
        }
    }
}

// MARK: - NumbersViewController

final class NumbersViewController: EmptiableStateViewController<NumbersView, NumbersViewModel> {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        emptyContentMessage = .init(icon: UIImage(systemName: "doc.fill"), message: "No numbers loaded.")
        contentView.axis = .vertical
        contentView.alignment = .center
        contentView.spacing = 8
    }
}
