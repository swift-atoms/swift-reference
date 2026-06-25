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

// `weak` storage and `AnyObject`-constrained classes require runtime
// reference-counting metadata unavailable in Embedded Swift.
#if !hasFeature(Embedded)

    extension Reference {
        /// A weak reference wrapper.
        ///
        /// Provides explicit weak reference semantics for any class instance.
        /// The reference becomes `nil` when the referenced object is deallocated.
        ///
        /// ## Example
        ///
        /// ```swift
        /// class Node { var name: String }
        /// let node = Node(name: "root")
        /// let weak = Reference.Weak(node)
        /// print(weak.value?.name)  // Optional("root")
        /// ```
        public struct Weak<Object: AnyObject>: Sendable where Object: Sendable {
            /// The weakly-referenced object, or `nil` if deallocated.
            public weak var value: Object?

            /// Creates a weak reference to the given object.
            @inlinable
            public init(_ value: Object?) {
                self.value = value
            }
        }
    }

#endif
