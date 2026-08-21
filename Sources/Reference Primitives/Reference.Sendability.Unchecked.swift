extension Reference.Sendability {

    public struct Unchecked<Value: ~Copyable>: ~Copyable, @unchecked Swift.Sendable {

        public let value: Value

        @inlinable
        public init(__unchecked value: consuming Value) {
            self.value = value
        }
    }
}
