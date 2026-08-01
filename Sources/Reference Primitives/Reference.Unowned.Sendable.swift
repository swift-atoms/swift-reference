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

    extension Reference.Unowned {

        /// Namespace for Sendable opt-ins.
        public enum Sendable {}
    }

#endif
