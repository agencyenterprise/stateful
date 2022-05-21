//
//  StatefulTests.swift
//  StatefulTests
//
//  Created by Lucas Assis Rodrigues on 5/19/22.
//

@testable import Stateful
import XCTest

class StatefulTests: XCTestCase {
    enum Error: Swift.Error { case test }

    func testStateSequence() throws {
        // GIVEN
        var pastStates: [StateMachine<Int, Error>] = []
        var state = StateMachine<Int, Error>() {
            didSet { pastStates.append(state) }
        }
        pastStates.append(state)

        // WHEN
        state.received(error: .test)

        state.receivedLoading()
        state.received(content: 1)

        state.receivedLoading()
        state.received(content: 2)

        state.receivedLoading()
        state.received(error: .test)

        state.receivedLoading()
        state.received(content: 3)

        // THEN
        XCTAssertEqual(
            pastStates,
            [
                .loading(content: nil),
                .error(error: .test, content: nil),
                .loading(content: nil),
                .content(content: 1),
                .loading(content: 1),
                .content(content: 2),
                .loading(content: 2),
                .error(error: .test, content: 2),
                .loading(content: 2),
                .content(content: 3)
            ]
        )
    }
}
