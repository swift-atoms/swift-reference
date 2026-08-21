#if !hasFeature(Embedded)

    extension Reference.Unowned.Sendable {

        public struct Unchecked: @unchecked Swift.Sendable {

            public unowned let value: Object

            @inlinable
            public init(_ value: Object) {
                self.value = value
            }
        }
    }

#endif
