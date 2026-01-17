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
    /// A heap-allocated wrapper enabling recursive value types.
    ///
    /// Use `Indirect` to break the infinite-size cycle in recursive
    /// struct/enum definitions by adding a level of indirection.
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
    public final class Indirect<Value>: @unchecked Sendable where Value: Sendable {
        /// The wrapped value.
        public var value: Value

        /// Creates an indirect wrapper containing the given value.
        @inlinable
        public init(_ value: Value) {
            self.value = value
        }
    }
}
