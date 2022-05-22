//
//  SceneDelegate.swift
//  StatefulExample
//
//  Created by Lucas Assis Rodrigues on 5/20/22.
//

import Stateful
import UIKit

// MARK: - SceneDelegate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        window?.rootViewController = UINavigationController(
            rootViewController: ViewController(viewModel: ViewModel())
        )
        window?.makeKeyAndVisible()
    }
}

typealias Content = [Int]

// MARK: - Array + Emptiable

extension Array: Emptiable {
    public static var empty: Self { [] }
}

// MARK: - ScrollView

final class ScrollView: UIScrollView, ContentBindable {
    var numbers: Content = [] {
        didSet { view.numbers = numbers }
    }

    var view = View()

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        alwaysBounceVertical = true
        contentInsetAdjustmentBehavior = .always

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentView)

        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(view)

        NSLayoutConstraint.activate(
            [
                contentView.topAnchor.constraint(equalTo: topAnchor),
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
                contentView.widthAnchor.constraint(equalTo: widthAnchor),

                view.topAnchor.constraint(equalTo: contentView.topAnchor),
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ]
        )
    }

    func bind(content: View.Content) {
        view.bind(content: content)
    }
}
