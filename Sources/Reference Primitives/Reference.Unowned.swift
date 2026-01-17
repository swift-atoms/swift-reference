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
    /// An unowned reference wrapper.
    ///
    /// Provides explicit unowned reference semantics. Accessing `value`
    /// after the referenced object is deallocated is undefined behavior.
    ///
    /// Use when you guarantee the referenced object outlives this wrapper.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class Parent { var children: [Child] = [] }
    /// class Child { let parent: Reference.Unowned<Parent> }
    /// ```
    public struct Unowned<Object: AnyObject>: @unchecked Sendable {
        /// The unowned reference to the object.
        public unowned let value: Object

        /// Creates an unowned reference to the given object.
        @inlinable
        public init(_ value: Object) {
            self.value = value
        }
    }
}
