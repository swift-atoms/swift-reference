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
    /// A heap-allocated wrapper for a value.
    ///
    /// `Box` provides reference semantics for value types, enabling:
    /// - Heap allocation for values that need stable identity
    /// - Type erasure via `Unmanaged` + `UnsafeRawPointer`
    /// - Breaking recursive type definitions
    /// - Storage for `~Copyable` types that need heap allocation
    ///
    /// ## Example
    ///
    /// ```swift
    /// let boxed = Reference.Box(42)
    /// print(boxed.value)  // 42
    /// ```
    @safe
    public final class Box<Value: ~Copyable & Sendable>: @unchecked Sendable {
        /// The wrapped value.
        public let value: Value

        /// Creates a box containing the given value.
        @inlinable
        public init(_ value: consuming Value) {
            self.value = value
        }
    }
}
