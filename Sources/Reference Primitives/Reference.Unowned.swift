#if !hasFeature(Embedded)

    extension Reference {

        public struct Unowned<Object: AnyObject> {

            public unowned let value: Object

            @inlinable
            public init(_ value: Object) {
                self.value = value
            }
        }
    }

#endif
