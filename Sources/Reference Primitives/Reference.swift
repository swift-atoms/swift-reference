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

/// A namespace for non-owning reference types used in relationship modeling.
///
/// These types refer to objects without owning them—they do not participate in
/// ownership or lifetime management of the referenced objects.
///
/// ## Types
///
/// | Type | Relationship | Sendable |
/// |------|--------------|----------|
/// | ``Weak`` | Zeroing weak reference | When `Object: Sendable` |
/// | ``Unowned`` | Unsafe unowned reference | Via `.Sendable.*` variants |
/// | ``Sendability.Unchecked`` | Sendability escape hatch | `@unchecked` (assertion) |
///
/// ## Design Philosophy
///
/// This module provides non-owning reference semantics:
///
/// - Need weak back-references that zero on deallocation? → ``Weak``
/// - Need unowned parent pointers? → ``Unowned``
/// - Need unchecked sendability assertion? → ``Sendability.Unchecked``
///
/// ## Relationship to Ownership Primitives
///
/// For types that **own** values, see `Ownership_Primitives`:
/// - `Ownership.Unique`: Exclusive ownership with deterministic cleanup
/// - `Ownership.Shared`: Shared immutable ownership via ARC
/// - `Ownership.Mutable`: Shared mutable ownership via ARC
/// - `Ownership.Slot`: Reusable ownership slot with atomic semantics
/// - `Ownership.Transfer`: Cross-boundary ownership transfer
///
/// ## Sendable Policy
///
/// **Principle:** Non-owning reference types that may reference non-Sendable
/// objects are NOT Sendable by default.
///
/// ### Weak references
/// - `Weak`: Sendable when `Object: Sendable` (value semantics, safe to share)
///
/// ### Unowned references (not Sendable by default)
/// - `Unowned`: Not Sendable. Use `Unowned.Sendable.Checked` (compiler-verified)
///   or `Unowned.Sendable.Unchecked` (explicit escape hatch).
///
/// ### Escape hatches
/// - `Sendability.Unchecked`: Wraps any value as `@unchecked Sendable`. Provides
///   no guarantees—exists solely as an auditable assertion site for values the
///   compiler cannot prove sendable but the programmer can reason about.
///
/// ## Backward Compatibility
///
/// The following types have been moved to `Ownership_Primitives` with deprecated
/// typealiases provided for migration:
///
/// | Old Name | New Name |
/// |----------|----------|
/// | `Reference.Box` | `Ownership.Shared` |
/// | `Reference.Indirect` | `Ownership.Mutable` |
/// | `Reference.Slot` | `Ownership.Slot` |
/// | `Reference.Transfer` | `Ownership.Transfer` |
public enum Reference {}
