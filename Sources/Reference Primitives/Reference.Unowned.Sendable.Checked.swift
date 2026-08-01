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

        /// A checked-Sendable unowned reference.
        ///
        /// This wrapper is `Sendable` because the referenced object type
        /// is constrained to `Sendable`. This is fully compiler-checked.
        ///
        /// ## Example
        ///
        /// ```swift
        /// class SafeParent: Sendable { }
        /// let ref = Reference.Unowned<SafeParent>.Sendable.Checked(parent)
        /// ```
        public struct Checked: Swift.Sendable where Object: Swift.Sendable {

            /// The unowned reference to the object.
            public unowned let value: Object

            /// Creates a checked-Sendable unowned reference.
            ///
            /// - Parameter value: The object to reference.
            @inlinable
            public init(_ value: Object) {
                self.value = value
            }
        }
    }

#endif
