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

// `unowned` storage and `AnyObject`-constrained classes require runtime
// reference-counting metadata unavailable in Embedded Swift.
#if !hasFeature(Embedded)

    extension Reference.Unowned.Sendable {

        /// An unchecked-Sendable unowned reference.
        ///
        /// ## Safety
        ///
        /// **This type bypasses the compiler's Sendable checking.**
        ///
        /// The caller must ensure the referenced object is not accessed
        /// concurrently across isolation domains. Failure to do so will
        /// cause data races.
        ///
        /// ## Intended Use Cases
        ///
        /// - Actor-confined parent references where the child never escapes
        /// - Single-threaded contexts with non-Sendable class hierarchies
        ///
        /// ## Example
        ///
        /// ```swift
        /// class NonSendableParent { var children: [Child] = [] }
        /// class Child {
        ///     // Only valid if Child never escapes the parent's isolation domain
        ///     let parent: Reference.Unowned<NonSendableParent>.Sendable.Unchecked
        /// }
        /// ```
        public struct Unchecked: @unchecked Swift.Sendable {

            /// The unowned reference to the object.
            public unowned let value: Object

            /// Creates an unchecked-Sendable unowned reference.
            ///
            /// - Parameter value: The object to reference.
            @inlinable
            public init(_ value: Object) {
                self.value = value
            }
        }
    }

#endif
