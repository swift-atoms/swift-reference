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

import Synchronization

extension Reference.Transfer {
    /// ARC-managed box for ~Copyable value storage with atomic one-shot enforcement.
    ///
    /// Thread-safe: take() and store() use atomic operations to ensure exactly-once
    /// semantics even if tokens are duplicated (Copyable tokens with Sendable).
    ///
    /// @unchecked Sendable because:
    /// - Atomic operations protect mutable state
    /// - Storage pointer access is serialized by atomic flag
    @safe
    @usableFromInline
    internal final class _Box<T: ~Copyable>: @unchecked Sendable {
        /// Atomic state: 0 = empty, 1 = has value, 2 = taken/consumed
        private let _state: Atomic<Int>

        /// Storage for the value. Access protected by _state transitions.
        @usableFromInline
        var _storage: UnsafeMutablePointer<T>?

        /// Creates a box containing a value.
        @usableFromInline
        init(_ value: consuming T) {
            _state = Atomic(1)  // has value
            _storage = .allocate(capacity: 1)
            _storage!.initialize(to: value)
        }

        /// Creates an empty box (for Storage pattern).
        @usableFromInline
        init() {
            _state = Atomic(0)  // empty
            _storage = nil
        }

        /// Atomically stores a value. Traps if already has a value or already taken.
        @usableFromInline
        func store(_ value: consuming T) {
            // Atomically transition: 0 (empty) -> 1 (has value)
            let (exchanged, original) = _state.compareExchange(
                expected: 0,
                desired: 1,
                ordering: .acquiringAndReleasing
            )
            if !exchanged {
                if original == 1 {
                    preconditionFailure("Reference.Transfer: store() called when value already present - this is a bug")
                } else {
                    preconditionFailure("Reference.Transfer: store() called after take() - this is a bug")
                }
            }
            _storage = .allocate(capacity: 1)
            _storage!.initialize(to: value)
        }

        /// Atomically takes the value. Traps if no value or already taken.
        @usableFromInline
        func take() -> T {
            // Atomically transition: 1 (has value) -> 2 (taken)
            let (exchanged, original) = _state.compareExchange(
                expected: 1,
                desired: 2,
                ordering: .acquiringAndReleasing
            )
            if !exchanged {
                if original == 0 {
                    preconditionFailure("Reference.Transfer: take() called when no value present - this is a bug")
                } else {
                    preconditionFailure("Reference.Transfer: take() called twice - this is a bug")
                }
            }
            let ptr = _storage!
            _storage = nil
            let value = ptr.move()
            ptr.deallocate()
            return value
        }

        /// Atomically takes the value if present, otherwise returns nil.
        @usableFromInline
        func takeIfPresent() -> T? {
            // Atomically transition: 1 (has value) -> 2 (taken)
            let (exchanged, _) = _state.compareExchange(
                expected: 1,
                desired: 2,
                ordering: .acquiringAndReleasing
            )
            guard exchanged else {
                return nil
            }
            let ptr = _storage!
            _storage = nil
            let value = ptr.move()
            ptr.deallocate()
            return value
        }

        /// Check if a value is present (for Storage.take() precondition).
        @usableFromInline
        var hasValue: Bool {
            _state.load(ordering: .acquiring) == 1
        }

        deinit {
            let state = _state.load(ordering: .acquiring)
            if state == 1, let ptr = _storage {
                // Value was never taken - clean up to avoid memory leak
                ptr.deinitialize(count: 1)
                ptr.deallocate()
            }
        }
    }
}
