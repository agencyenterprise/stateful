//
//  StateMachine+Combine.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/20/22.
//

import Combine

public extension CurrentValueSubject {
    convenience init<Content, Error>() where Output == StateMachine<Content, Error> {
        self.init(.loading(content: nil))
    }

    func sendLoading<Content, Error>() where Output == StateMachine<Content, Error> {
        send(value.receivingLoading())
    }

    func send<Content, Error>(error: Error) where Output == StateMachine<Content, Error> {
        send(value.receiving(error: error))
    }

    func send<Content, Error>(content: Content) where Output == StateMachine<Content, Error> {
        send(value.receiving(content: content))
    }

    func send<Content, Error>(result: Result<Content, Error>) where Output == StateMachine<Content, Error> {
        send(value.receiving(result: result))
    }

    func purge<Content, Error>() where Output == StateMachine<Content, Error> {
        send(value.purgingContentAndError())
    }
}
