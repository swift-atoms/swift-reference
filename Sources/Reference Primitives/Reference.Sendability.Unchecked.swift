// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-primitives
// project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Reference.Sendability {
    /// An unchecked-Sendable wrapper for an arbitrary value.
    ///
    /// ## Safety
    ///
    /// **This type bypasses the compiler's `Sendable` checking.**
    ///
    /// This wrapper provides **no runtime validation** and **no guarantees**.
    /// You assert that the wrapped value is safe to share across isolation
    /// domains in your program.
    ///
    /// ## Intended Use
    ///
    /// Use this wrapper when:
    /// - The compiler rejects a value for `Sendable` checking
    /// - You can prove safety through external reasoning
    ///
    /// Common examples:
    /// - `WritableKeyPath` capture in `@Sendable` closures
    /// - Third-party immutable types lacking `Sendable` conformance
    ///
    /// ## Non-Goals
    ///
    /// This is **not** a recommendation to wrap arbitrary values. It is an
    /// auditable assertion site. For domain types you control, prefer marking
    /// the containing type `@unchecked Sendable` so the assertion remains
    /// local to the domain.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let kp = Reference.Sendability.Unchecked(__unchecked: \DependencyValues.apiClient)
    ///
    /// let closure: @Sendable () -> Void = {
    ///     values[keyPath: kp.value] = mockClient
    /// }
    /// ```
    public struct Unchecked<Value: ~Copyable>: ~Copyable, @unchecked Swift.Sendable {
        /// The wrapped value.
        public let value: Value

        /// Creates an unchecked-Sendable wrapper.
        ///
        /// - Parameter value: The value to wrap.
        @inlinable
        public init(__unchecked value: consuming Value) {
            self.value = value
        }
    }
}
