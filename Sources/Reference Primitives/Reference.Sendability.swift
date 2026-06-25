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
    /// Namespace for Sendable-related escape hatches.
    ///
    /// Types in this namespace intentionally bypass the compiler's `Sendable`
    /// checking. They provide **no guarantees** and exist solely as auditable
    /// assertion sites.
    ///
    /// ## Policy
    ///
    /// This namespace is for cases where the compiler cannot prove sendability
    /// but the programmer can reason about safety through external analysis.
    /// It is **not** a general-purpose "make anything Sendable" toolkit.
    public enum Sendability {}
}
