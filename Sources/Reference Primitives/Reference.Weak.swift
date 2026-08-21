#if !hasFeature(Embedded)

    extension Reference {

        public struct Weak<Object: AnyObject>: Sendable where Object: Sendable {

            public weak var value: Object?

            @inlinable
            public init(_ value: Object?) {
                self.value = value
            }
        }
    }

#endif
