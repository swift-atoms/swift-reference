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

extension Reference {
    /// A heap-allocated wrapper enabling recursive value types and shared mutable state.
    ///
    /// `Indirect` boxes a value (including `~Copyable` types) in a reference type,
    /// enabling:
    /// - Breaking infinite-size cycles in recursive struct/enum definitions
    /// - Multiple owners sharing access to the same underlying storage
    /// - Heap allocation for values that need stable identity
    ///
    /// ## Access Patterns
    ///
    /// For `Copyable` values, direct property access is available:
    /// ```swift
    /// let indirect = Reference.Indirect(42)
    /// indirect.value += 1
    /// ```
    ///
    /// For `~Copyable` values or when scoped access is preferred, use closures:
    /// ```swift
    /// indirect.withValue { print($0) }
    /// indirect.update { $0 += 1 }
    /// ```
    ///
    /// ## Thread Safety
    ///
    /// `Indirect` itself provides no synchronization. If the boxed value needs
    /// thread-safe access, wrap a synchronized type (e.g., `Mutex`).
    ///
    /// ## Sendable
    ///
    /// `Indirect` is **not** `Sendable` by design. It is an identity-sharing mutable
    /// reference wrapper without synchronization. Sending it across isolation domains
    /// would allow concurrent mutation without protection—a data race.
    ///
    /// For use cases requiring capture of values in `@Sendable` closures (e.g., async
    /// iterator boxing), use ``Unchecked`` instead. This is an explicit opt-in to
    /// bypass Sendable checking—you take responsibility for ensuring single-consumer
    /// or externally-synchronized access.
    ///
    /// **Policy:** No general-purpose mutable reference wrapper in this module is
    /// `Sendable` unless it provides synchronization or actor isolation by construction.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct TreeNode {
    ///     var value: Int
    ///     var children: [Reference.Indirect<TreeNode>]
    /// }
    /// ```
    @safe
    public final class Indirect<Value: ~Copyable> {
        /// The wrapped value.
        @usableFromInline
        var _value: Value

        /// Direct access to the wrapped value.
        ///
        /// For `~Copyable` types, prefer `withValue(_:)` or `update(_:)` for
        /// safer scoped access.
        @inlinable
        public var value: Value {
            _read { yield _value }
            _modify { yield &_value }
        }

        /// Creates an indirect wrapper containing the given value.
        @inlinable
        public init(_ value: consuming Value) {
            self._value = value
        }

        /// Accesses the value for reading.
        ///
        /// - Parameter body: A closure that receives the value.
        /// - Returns: The result of the closure.
        @inlinable
        public func withValue<Result>(
            _ body: (borrowing Value) throws -> Result
        ) rethrows -> Result {
            try body(_value)
        }

        /// Accesses the value for mutation.
        ///
        /// - Parameter body: A closure that receives an inout reference to the value.
        /// - Returns: The result of the closure.
        @inlinable
        public func update<Result>(
            _ body: (inout Value) throws -> Result
        ) rethrows -> Result {
            try body(&_value)
        }
    }
}

// Indirect is intentionally NOT Sendable.
// Use Reference.Indirect.Unchecked for explicit opt-in to cross-isolation transfer.

extension Reference.Indirect where Value: ~Copyable {
    /// An unchecked-Sendable wrapper for `Indirect` that allows crossing
    /// concurrency boundaries with any value.
    ///
    /// ## Safety
    ///
    /// **This type bypasses the compiler's Sendable checking.**
    ///
    /// - **Single-consumer only.** Do not capture in multiple concurrent tasks.
    /// - **NOT thread-safe.** You are responsible for ensuring proper synchronization.
    /// - Concurrent mutation will cause data races (no runtime trap, silent corruption).
    ///
    /// ## Intended Use Cases
    ///
    /// - Boxing non-Sendable async iterators for capture in `@Sendable` closures
    /// - Single-writer patterns where the writer is the only accessor
    /// - Actor-confined usage where the wrapper never escapes the actor
    ///
    /// ## Example
    ///
    /// ```swift
    /// // CORRECT: Single consumer
    /// let box = Reference.Indirect.Unchecked(asyncIterator)
    /// Task {
    ///     while let value = await box.indirect.value.next() {
    ///         process(value)
    ///     }
    /// }
    ///
    /// // INCORRECT: Multiple consumers — DATA RACE
    /// let box = Reference.Indirect.Unchecked(asyncIterator)
    /// Task { await box.indirect.value.next() }  // Race!
    /// Task { await box.indirect.value.next() }  // Race!
    /// ```
    public struct Unchecked: @unchecked Sendable {
        /// The wrapped `Indirect` instance.
        public let indirect: Reference.Indirect<Value>

        /// Creates an unchecked-Sendable wrapper containing the given value.
        @inlinable
        public init(_ value: consuming Value) {
            self.indirect = Reference.Indirect(value)
        }
    }
}
