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
    /// A heap-allocated wrapper for an immutable value.
    ///
    /// `Box` provides reference semantics for value types, enabling:
    /// - Heap allocation for values that need stable identity
    /// - Type erasure via `Unmanaged` + `UnsafeRawPointer`
    /// - Breaking recursive type definitions
    /// - Storage for `~Copyable` types that need heap allocation
    ///
    /// ## Sendable
    ///
    /// `Box` is `Sendable` when `Value: Sendable`. The value is immutable (`let`),
    /// so sharing across isolation domains is safe.
    ///
    /// **Note:** This type uses `@unchecked Sendable` due to a Swift compiler
    /// limitation where `~Copyable` generic parameters in class stored properties
    /// prevent checked `Sendable` conformance inference. The type is structurally
    /// safe: the stored `value` is immutable and requires `Value: Sendable`.
    /// When this compiler limitation is resolved, this should be converted to
    /// checked `Sendable` conformance.
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
