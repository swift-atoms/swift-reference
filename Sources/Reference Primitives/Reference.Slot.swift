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

extension Reference {
    /// A reusable heap-allocated slot for storing a single `~Copyable` value.
    ///
    /// Unlike `Reference.Box` which holds an immutable value, `Slot` allows
    /// values to be stored and taken repeatedly. This is useful for:
    /// - Resource pools with reusable entries
    /// - Lifetime management patterns
    /// - Any pattern requiring heap storage with move-in/move-out semantics
    ///
    /// The key difference from `Reference.Transfer`:
    /// - `Transfer`: One-shot (empty → filled → taken, then done)
    /// - `Slot`: Reusable (empty ↔ filled, can cycle indefinitely)
    ///
    /// ## Thread Safety
    ///
    /// All operations are atomic. The slot can be safely shared across threads,
    /// though only one thread will succeed at any given store/take operation.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let slot = Reference.Slot<Resource>()
    /// slot.move.in(resource)
    /// print(slot.isFull)  // true
    ///
    /// let r = slot.move.out
    /// print(slot.isEmpty) // true
    ///
    /// slot.move.in(anotherResource)  // Can reuse!
    /// ```
    @safe
    public final class Slot<Value: ~Copyable & Sendable>: @unchecked Sendable {
        /// Atomic state: true = occupied, false = empty.
        private let _state: Atomic<Bool>

        /// Preallocated storage for the value. Always allocated, even when empty.
        /// This avoids allocation on the hot path (store/take operations).
        @usableFromInline
        let _storage: UnsafeMutablePointer<Value>

        /// Creates an empty slot.
        ///
        /// Storage is preallocated but uninitialized.
        public init() {
            _state = Atomic(false)
            unsafe _storage = .allocate(capacity: 1)
        }

        /// Creates a slot containing the given value.
        ///
        /// - Parameter value: The value to store (ownership transferred).
        public init(_ value: consuming Value) {
            _state = Atomic(true)
            unsafe _storage = .allocate(capacity: 1)
            unsafe _storage.initialize(to: value)
        }

        deinit {
            if _state.load(ordering: .acquiring) {
                unsafe _storage.deinitialize(count: 1)
            }
            unsafe _storage.deallocate()
        }
    }
}

// MARK: - State Inspection

extension Reference.Slot where Value: ~Copyable & Sendable {
    /// Whether the slot is empty.
    public var isEmpty: Bool {
        !_state.load(ordering: .acquiring)
    }

    /// Whether the slot contains a value.
    public var isFull: Bool {
        _state.load(ordering: .acquiring)
    }
}

// MARK: - Store Operations

extension Reference.Slot where Value: ~Copyable & Sendable {
    /// Atomically stores a value into the slot.
    ///
    /// - Parameter value: The value to store (ownership transferred).
    /// - Precondition: The slot must be empty. Traps if already occupied.
    public func store(_ value: consuming Value) {
        let (exchanged, _) = _state.compareExchange(
            expected: false,
            desired: true,
            ordering: .acquiringAndReleasing
        )
        precondition(exchanged, "Reference.Slot: store() called when already occupied")
        unsafe _storage.initialize(to: value)
    }

    /// Atomically stores a value into the slot if empty.
    ///
    /// - Parameter value: The value to store (ownership transferred).
    /// - Returns: `true` if stored successfully, `false` if slot was occupied.
    ///
    /// If the slot is occupied, the value is consumed but discarded.
    /// Use this when you need non-trapping store semantics.
    @discardableResult
    public func storeIfEmpty(_ value: consuming Value) -> Bool {
        let (exchanged, _) = _state.compareExchange(
            expected: false,
            desired: true,
            ordering: .acquiringAndReleasing
        )
        if exchanged {
            unsafe _storage.initialize(to: value)
            return true
        }
        // Value is consumed but not stored
        _ = consume value
        return false
    }
}

// MARK: - Take Operations

extension Reference.Slot where Value: ~Copyable & Sendable {
    /// Atomically takes the value from the slot.
    ///
    /// - Returns: The stored value.
    /// - Precondition: The slot must be occupied. Traps if empty.
    public func take() -> Value {
        let (exchanged, _) = _state.compareExchange(
            expected: true,
            desired: false,
            ordering: .acquiringAndReleasing
        )
        precondition(exchanged, "Reference.Slot: take() called when empty")
        return unsafe _storage.move()
    }

    /// Atomically takes the value from the slot if present.
    ///
    /// - Returns: The stored value, or `nil` if empty.
    public func takeIfPresent() -> Value? {
        let (exchanged, _) = _state.compareExchange(
            expected: true,
            desired: false,
            ordering: .acquiringAndReleasing
        )
        guard exchanged else {
            return nil
        }
        return unsafe _storage.move()
    }
}

// MARK: - Move Accessor

extension Reference.Slot where Value: ~Copyable & Sendable {
    /// Accessor for move operations.
    public var move: Move {
        Move(slot: self)
    }
}

// MARK: - Move Type

extension Reference.Slot where Value: ~Copyable & Sendable {
    /// Namespace for value move operations.
    public struct Move {
        @usableFromInline
        let slot: Reference.Slot<Value>

        @usableFromInline
        init(slot: Reference.Slot<Value>) {
            self.slot = slot
        }
    }
}

// MARK: - Move Operations

extension Reference.Slot.Move where Value: ~Copyable & Sendable {
    /// Takes the value out of the slot.
    ///
    /// - Precondition: Slot must be occupied.
    /// - Returns: The stored value.
    public var out: Value {
        slot.take()
    }

    /// Puts a value into the slot.
    ///
    /// - Precondition: Slot must be empty.
    /// - Parameter value: The value to store.
    public func `in`(_ value: consuming Value) {
        slot.store(value)
    }
}
