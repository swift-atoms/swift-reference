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

// Conditionally Sendable: preserves compile-time safety for the common case.
// For use cases requiring capture of non-Sendable values in @Sendable closures
// (e.g., async iterator boxing), use Reference.Indirect.Unchecked instead.
extension Reference.Indirect: @unchecked Sendable where Value: Sendable {}

extension Reference.Indirect {
    /// An unchecked-Sendable wrapper for `Indirect` that allows crossing
    /// concurrency boundaries with non-Sendable values.
    ///
    /// **Use with caution.** This type bypasses the compiler's Sendable checking.
    /// You are responsible for ensuring that concurrent access is properly synchronized.
    ///
    /// ## Intended Use Cases
    ///
    /// - Boxing non-Sendable async iterators for capture in `@Sendable` closures
    /// - Single-writer/multiple-reader patterns with external synchronization
    ///
    /// ## Example
    ///
    /// ```swift
    /// let box = Reference.Indirect.Unchecked(nonSendableIterator)
    /// Task {
    ///     await box.indirect.value.next()
    /// }
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
