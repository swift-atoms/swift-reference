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
/// Reference Primitives has no dependencies (Tier 0). It provides pure
/// non-owning reference types that depend only on Swift's built-in
/// reference semantics (weak, unowned).
///
/// For owning types, import `Ownership_Primitives` directly.
