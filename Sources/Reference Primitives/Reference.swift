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

/// Reference Primitives
///
/// This module provides a family of reference semantics primitives for Swift.
/// Each type offers a distinct ownership, mutability, or concurrency contract.
/// Choose the type whose contract matches your use case.
///
/// ## Types
///
/// | Type | Ownership | Mutability | Sendable |
/// |------|-----------|------------|----------|
/// | ``Box`` | Strong | Immutable | When `Value: Sendable` |
/// | ``Indirect`` | Strong | Mutable | Not Sendable (use `.Unchecked`) |
/// | ``Weak`` | Weak | N/A | When `Object: Sendable` |
/// | ``Unowned`` | Unowned | N/A | Not Sendable (use `.Sendable.*`) |
/// | ``Slot`` | Strong | Move semantics | `@unchecked` (atomic sync) |
/// | ``Transfer`` | One-shot | Move-only | Tokens are Sendable |
///
/// ## Design Philosophy
///
/// This module provides capabilities with distinct ownership/mutability/transfer
/// contracts. There is no single default; choose by contract:
///
/// - Need immutable heap storage? → ``Box``
/// - Need mutable shared state? → ``Indirect``
/// - Need weak back-references? → ``Weak``
/// - Need atomic move semantics? → ``Slot``
/// - Need cross-boundary ownership transfer? → ``Transfer``
///
/// ## Sendable Policy
///
/// **Principle:** Mutable reference wrappers are NOT Sendable by default.
/// Crossing isolation boundaries requires explicit opt-in.
///
/// ### Immutable types
/// - `Box`: Sendable when `Value: Sendable` (immutable, safe to share)
/// - `Weak`: Sendable when `Object: Sendable` (value semantics)
///
/// ### Mutable types (not Sendable by default)
/// - `Indirect`: Not Sendable. Use `Indirect.Unchecked` for explicit opt-in.
/// - `Unowned`: Not Sendable. Use `Unowned.Sendable.Checked` (compiler-verified)
///   or `Unowned.Sendable.Unchecked` (explicit escape hatch).
///
/// ### Synchronized types
/// - `Slot`: `@unchecked Sendable` because atomic state machine provides
///   synchronization. Safe publication via release/acquire on state transitions.
/// - `Transfer`: Tokens are Sendable. Exactly-once semantics enforced atomically.
///
/// This policy prevents "just add @unchecked Sendable to make it compile"
/// regressions while providing explicit, auditable opt-ins where needed.
public enum Reference {}
