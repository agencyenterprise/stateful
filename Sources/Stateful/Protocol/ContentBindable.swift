//
//  ContentBindable.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/19/22.
//

#if os(iOS)
    import UIKit

    // MARK: - ContentBindable

    /// An entity that can receive content.
    public protocol ContentBindable: UIView {
        associatedtype Content

        /// Entry point to assing content to the entity.
        /// - Parameter content: Content to be bound.
        func bind(content: Content)
    }
#endif
