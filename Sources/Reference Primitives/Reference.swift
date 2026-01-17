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
/// | ``Indirect`` | Strong | Mutable | When `Value: Sendable` |
/// | ``Weak`` | Weak | N/A | When `Object: Sendable` |
/// | ``Unowned`` | Unowned | N/A | `@unchecked` |
/// | ``Slot`` | Strong | Move semantics | `@unchecked` |
/// | ``Transfer`` | One-shot | Move-only | Sendable |
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
/// Default wrapper types are Sendable only when their payload is Sendable.
/// Only explicitly-unsafe types (named `Unchecked` or `Unsafe`) may be
/// `@unchecked Sendable` for mutable shared state. This prevents
/// "just add unchecked Sendable to make it compile" regressions.
public enum Reference {}
