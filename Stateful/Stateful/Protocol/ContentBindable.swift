//
//  ContentBindable.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/19/22.
//

import UIKit

// MARK: - ContentBindable

public protocol ContentBindable: UIView {
    associatedtype Content
    func bind(content: Content)
}
