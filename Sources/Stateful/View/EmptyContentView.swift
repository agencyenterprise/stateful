//
//  EmptyContentView.swift
//  Stateful
//
//  Created by Lucas Assis Rodrigues on 5/20/22.
//

#if os(iOS)
    import UIKit

    // MARK: - EmptyContentView

    open class EmptyContentView: UIStackView {
        public final let icon = UIImageView()
        public final let message = UILabel()

        override open var tintColor: UIColor! {
            didSet { message.textColor = tintColor }
        }

        public convenience init(icon: UIImage? = nil, message: String = "") {
            self.init(frame: .zero)
            bind(content: .init(icon: icon, message: message))
        }

        override public init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }

        public required init(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }

        open func commonInit() {
            axis = .vertical
            alignment = .center
            spacing = 16

            tintColor = .secondaryLabel

            icon.apply { $0.contentMode = .scaleAspectFit }
                .let(addArrangedSubview)

            message.apply {
                $0.font = .preferredFont(forTextStyle: .body)
                $0.textAlignment = .center
                $0.numberOfLines = 0
            }
            .let(addArrangedSubview)
        }
    }

    // MARK: - EmptyContentView + ContentBindable

    extension EmptyContentView: ContentBindable {}
    public extension EmptyContentView {
        struct Content: Emptiable, Equatable {
            let icon: UIImage?
            let message: String

            public static var empty: Self { .init(icon: nil, message: "") }

            public init(icon: UIImage? = nil, message: String) {
                self.icon = icon
                self.message = message
            }
            
            public var isEmpty: Bool { self == .empty }
        }

        func bind(content: Content) {
            icon.image = content.icon
            message.text = content.message
        }

        func bind(icon: UIImage? = nil, message: String) { bind(content: .init(icon: icon, message: message)) }
        func bind(icon: UIImage? = nil, error: Error) { bind(icon: icon, message: error.localizedDescription) }
    }
#endif
