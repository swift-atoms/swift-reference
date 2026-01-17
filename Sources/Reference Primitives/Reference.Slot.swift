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

// MARK: - Hoisted State Constants

/// State constants for Reference.Slot state machine.
///
/// Hoisted to module scope due to Swift limitation: static stored properties
/// are not supported in generic types. Refer via `Reference.Slot.State`.
@usableFromInline
enum __SlotState {
    @usableFromInline static let empty: UInt8 = 0
    @usableFromInline static let initializing: UInt8 = 1
    @usableFromInline static let full: UInt8 = 2
}

// MARK: - Slot

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
    /// ## Totality
    ///
    /// Primary operations return results rather than trapping:
    /// - `store(_:)` returns `Store` indicating success or returning the value
    /// - `take()` returns `Value?`
    ///
    /// Trapping variants are available via `__unchecked` overloads for contexts
    /// where failure indicates a logic error.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let slot = Reference.Slot<Resource>()
    ///
    /// switch slot.store(resource) {
    /// case .stored:
    ///     print("Resource stored")
    /// case .occupied(let returned):
    ///     print("Slot was full, got resource back")
    /// }
    ///
    /// if let r = slot.take() {
    ///     print("Got resource: \(r)")
    /// }
    /// ```
    @safe
    public final class Slot<Value: ~Copyable & Sendable>: @unchecked Sendable {
        // MARK: - State Machine
        //
        // ## Publication Protocol (release/acquire)
        //
        // Store path:
        //   1. CAS empty → initializing (acquiringAndReleasing) — reserves slot
        //   2. _storage.initialize(to:) — writes non-atomic memory
        //   3. store(State.full, releasing) — publishes; release barrier ensures
        //      initialize happens-before any observer sees .full
        //
        // Take path:
        //   1. CAS full → empty (acquiringAndReleasing) — acquire barrier ensures
        //      we observe all writes that happened-before the release in store
        //   2. _storage.move() — safe because we acquired the publication
        //
        // ## Invariants
        //
        // - State.full implies _storage is initialized and safe to move/deinit
        // - State.initializing is transient; no observer can take until .full
        // - _storage is non-atomic; all access is serialized by state transitions
        //
        // States:
        // - State.empty (0): storage uninitialized
        // - State.initializing (1): exclusive writer reserved; init in progress
        // - State.full (2): storage initialized; may be taken

        /// State constants for the slot state machine.
        @usableFromInline
        typealias State = __SlotState

        /// Atomic state for the slot.
        private let _state: Atomic<UInt8>

        /// Preallocated storage for the value. Always allocated, even when empty.
        /// This avoids allocation on the hot path (store/take operations).
        @usableFromInline
        let _storage: UnsafeMutablePointer<Value>

        /// Creates an empty slot.
        ///
        /// Storage is preallocated but uninitialized.
        public init() {
            _state = Atomic(State.empty)
            unsafe _storage = .allocate(capacity: 1)
        }

        /// Creates a slot containing the given value.
        ///
        /// - Parameter value: The value to store (ownership transferred).
        public init(_ value: consuming Value) {
            _state = Atomic(State.initializing)
            unsafe _storage = .allocate(capacity: 1)
            unsafe _storage.initialize(to: value)
            _state.store(State.full, ordering: .releasing)
        }

        deinit {
            let prior = _state.exchange(State.empty, ordering: .acquiringAndReleasing)
            if prior == State.full {
                unsafe _storage.deinitialize(count: 1)
            }
            // State.initializing at deinit indicates a logic bug (store in progress
            // when object deallocated). In release builds we treat as empty.
            unsafe _storage.deallocate()
        }
    }
}

// MARK: - Store Result

extension Reference.Slot where Value: ~Copyable {
    /// Result of a total store operation.
    ///
    /// For `~Copyable` values, this enum ensures the value is never silently
    /// discarded on failure—it is returned to the caller for handling.
    public enum Store: ~Copyable {
        /// The value was successfully stored in the slot.
        case stored
        /// The slot was already occupied. The value is returned unconsumed.
        case occupied(Value)
    }
}

// MARK: - State Inspection

extension Reference.Slot {
    /// Whether the slot is empty.
    ///
    /// Note: The intermediate "initializing" state is not considered empty
    /// (a store is in progress), but is also not full (cannot be taken).
    public var isEmpty: Bool {
        _state.load(ordering: .acquiring) == State.empty
    }

    /// Whether the slot contains a value that can be taken.
    public var isFull: Bool {
        _state.load(ordering: .acquiring) == State.full
    }
}

// MARK: - Store Operations

extension Reference.Slot where Value: ~Copyable {
    /// Atomically stores a value into the slot.
    ///
    /// This is the primary, total store operation. If the slot is occupied,
    /// the value is returned to the caller rather than being discarded.
    ///
    /// - Parameter value: The value to store (ownership transferred on success).
    /// - Returns: `.stored` on success, or `.occupied(value)` if the slot was full.
    public func store(_ value: consuming Value) -> Store {
        // Reserve: CAS empty -> initializing
        let (reserved, _) = _state.compareExchange(
            expected: State.empty,
            desired: State.initializing,
            ordering: .acquiringAndReleasing
        )
        guard reserved else {
            return .occupied(value)
        }

        // Initialize storage
        unsafe _storage.initialize(to: value)

        // Publish: store full (release ensures init is visible to takers)
        _state.store(State.full, ordering: .releasing)
        return .stored
    }

    /// Atomically stores a value into the slot, trapping if occupied.
    ///
    /// Use this when failure indicates a logic error in the calling code.
    ///
    /// - Parameter value: The value to store (ownership transferred).
    /// - Precondition: The slot must be empty.
    public func store(__unchecked value: consuming Value) {
        switch store(value) {
        case .stored:
            return
        case .occupied:
            preconditionFailure("Reference.Slot.store(__unchecked:): already occupied")
        }
    }
}

// MARK: - Take Operations

extension Reference.Slot where Value: ~Copyable {
    /// Atomically takes the value from the slot if present.
    ///
    /// This is the primary, total take operation.
    ///
    /// - Returns: The stored value, or `nil` if empty.
    public func take() -> Value? {
        // CAS full -> empty
        let (exchanged, _) = _state.compareExchange(
            expected: State.full,
            desired: State.empty,
            ordering: .acquiringAndReleasing
        )
        guard exchanged else {
            return nil
        }
        return unsafe _storage.move()
    }

    /// Atomically takes the value from the slot, trapping if empty.
    ///
    /// Use this when failure indicates a logic error in the calling code.
    ///
    /// - Returns: The stored value.
    /// - Precondition: The slot must be occupied.
    public func take(__unchecked: Void) -> Value {
        guard let value = take() else {
            preconditionFailure("Reference.Slot.take(__unchecked:): already empty")
        }
        return value
    }
}

// MARK: - Move Accessor

extension Reference.Slot where Value: ~Copyable {
    /// Accessor for move operations using fluent syntax.
    ///
    /// Provides `slot.move.in(value)` and `slot.move.out` as alternatives
    /// to the trapping `store(__unchecked:)` and `take(__unchecked:)`.
    public var move: Move {
        Move(slot: self)
    }
}

// MARK: - Move Type

extension Reference.Slot where Value: ~Copyable {
    /// Namespace for fluent value move operations.
    ///
    /// These operations trap on failure—use the total `store(_:)` and `take()`
    /// methods when you need to handle failure gracefully.
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

extension Reference.Slot.Move where Value: ~Copyable {
    /// Takes the value out of the slot.
    ///
    /// - Precondition: Slot must be occupied.
    /// - Returns: The stored value.
    public var out: Value {
        slot.take(__unchecked: ())
    }

    /// Puts a value into the slot.
    ///
    /// - Precondition: Slot must be empty.
    /// - Parameter value: The value to store.
    public func `in`(_ value: consuming Value) {
        slot.store(__unchecked: value)
    }
}
