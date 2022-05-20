//
//  StatefulViewModel.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/20/22.
//

import Combine
import Foundation

// MARK: - StatefulViewModel

public protocol StatefulViewModel: AnyObject {
    associatedtype Content
    associatedtype Error: Swift.Error
    var state: CurrentValueSubject<StateMachine<Content, Error>, Never> { get }

    func loadContent(_ completion: @escaping (_ result: Result<Content, Error>) -> Void)
}

extension StatefulViewModel {
    func reload() {
        state.sendLoading()
        loadContent { [weak self] result in
            guard let self = self else { return }
            self.state.send(result: result)
        }
    }
}
