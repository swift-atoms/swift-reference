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
    /// This type is **not Sendable** by design. It may reference any class
    /// instance and is intended for local, isolation-confined use only.
    ///
    /// To explicitly cross isolation boundaries, use one of:
    /// - ``Reference.Unowned.Sendable.Checked`` (when `Object: Sendable`)
    /// - ``Reference.Unowned.Sendable.Unchecked`` (explicit opt-in)
    ///
    /// ## Example
    ///
    /// ```swift
    /// class Parent { var children: [Child] = [] }
    /// class Child { let parent: Reference.Unowned<Parent> }
    /// ```
    public struct Unowned<Object: AnyObject> {

        /// The unowned reference to the object.
        public unowned let value: Object

        /// Creates an unowned reference to the given object.
        @inlinable
        public init(_ value: Object) {
            self.value = value
        }
    }
}

extension Reference.Unowned {

    /// Namespace for Sendable opt-ins.
    public enum Sendable {

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
        public struct Checked<Subject: AnyObject & Swift.Sendable>: Swift.Sendable {

            /// The unowned reference to the object.
            public unowned let value: Subject

            /// Creates a checked-Sendable unowned reference.
            ///
            /// - Parameter value: The object to reference.
            @inlinable
            public init(_ value: Subject) {
                self.value = value
            }
        }

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
}
