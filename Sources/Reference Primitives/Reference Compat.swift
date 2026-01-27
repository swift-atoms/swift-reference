// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives
// project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

/// Backward compatibility typealiases for types moved to Ownership Primitives.
///
/// These typealiases allow existing code using `Reference.Box`, `Reference.Indirect`,
/// `Reference.Slot`, and `Reference.Transfer` to continue working while migrating
/// to the new `Ownership.*` names.
///
/// ## Migration Guide
///
/// | Old API | New API |
/// |---------|---------|
/// | `Reference.Box<T>` | `Ownership.Shared<T>` |
/// | `Reference.Indirect<T>` | `Ownership.Mutable<T>` |
/// | `Reference.Indirect.Unchecked` | `Ownership.Mutable.Unchecked` |
/// | `Reference.Slot<T>` | `Ownership.Slot<T>` |
/// | `Reference.Transfer.Cell<T>` | `Ownership.Transfer.Cell<T>` |
/// | `Reference.Transfer.Storage<T>` | `Ownership.Transfer.Storage<T>` |
/// | `Reference.Transfer.Retained<T>` | `Ownership.Transfer.Retained<T>` |
/// | `Reference.Transfer.Box` | `Ownership.Transfer.Box` |

extension Reference {
    /// A heap-allocated wrapper for an immutable value.
    ///
    /// - Important: This type has been moved to `Ownership.Shared`.
    ///   Update your code to use `Ownership.Shared` instead.
    @available(*, deprecated, renamed: "Ownership.Shared", message: "Use Ownership.Shared instead")
    public typealias Box<T: ~Copyable & Sendable> = Ownership.Shared<T>

    /// A heap-allocated wrapper enabling recursive value types and shared mutable state.
    ///
    /// - Important: This type has been moved to `Ownership.Mutable`.
    ///   Update your code to use `Ownership.Mutable` instead.
    @available(*, deprecated, renamed: "Ownership.Mutable", message: "Use Ownership.Mutable instead")
    public typealias Indirect<T: ~Copyable> = Ownership.Mutable<T>

    /// A reusable heap-allocated slot for storing a single `~Copyable` value.
    ///
    /// - Important: This type has been moved to `Ownership.Slot`.
    ///   Update your code to use `Ownership.Slot` instead.
    @available(*, deprecated, renamed: "Ownership.Slot", message: "Use Ownership.Slot instead")
    public typealias Slot<T: ~Copyable & Sendable> = Ownership.Slot<T>

    /// Namespace for cross-boundary ownership transfer primitives.
    ///
    /// - Important: This namespace has been moved to `Ownership.Transfer`.
    ///   Update your code to use `Ownership.Transfer` instead.
    @available(*, deprecated, renamed: "Ownership.Transfer", message: "Use Ownership.Transfer instead")
    public typealias Transfer = Ownership.Transfer
}
