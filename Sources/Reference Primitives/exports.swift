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

/// Re-export policy for Reference Primitives.
///
/// Reference Primitives re-exports Ownership Primitives, which re-exports
/// Pointer Primitives, which in turn re-exports:
/// - Memory Primitives
/// - Index Primitives
/// - Range Primitives
/// - Identity Primitives
/// - Hash Primitives
/// - Comparison Primitives
/// - Equation Primitives
/// - Ordinal Primitives
/// - Cardinal Primitives
///
/// Downstream packages importing Reference Primitives gain access to this
/// complete memory/pointer/ownership/reference ecosystem. This is a deliberate
/// convenience policy.

@_exported import Ownership_Primitives
