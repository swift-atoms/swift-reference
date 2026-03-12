---
name: reference-primitives
description: |
  Reference type primitives for ownership transfer and indirection.
  ALWAYS apply when working with heap indirection, ownership transfer,
  or move-only resource management.

layer: implementation

requires:
  - primitives
  - memory
  - naming

applies_to:
  - swift
  - swift-primitives
  - swift-reference-primitives
---

# Reference Primitives

Heap indirection and ownership transfer primitives.

---

## Core Design Decisions

### [REF-001] Reference Type Selection

**Statement**: Choose reference type based on ownership and mutability requirements.

| Type | Ownership | Mutability | Sendable |
|------|-----------|------------|----------|
| `Reference.Box` | Strong | Immutable | When `Value: Sendable` |
| `Reference.Indirect` | Strong | Mutable | Not Sendable |
| `Reference.Slot` | Strong | Move semantics | `@unchecked` |
| `Reference.Transfer` | One-shot | Move-only | Tokens are Sendable |

### [REF-002] Conservative Sendability

**Statement**: Mutable reference wrappers MUST NOT be unconditionally Sendable.

```swift
// CORRECT - conditional Sendable
extension Reference.Indirect: @unchecked Sendable where Value: Sendable {}

// CORRECT - explicit escape hatch
extension Reference.Indirect {
    public struct Unchecked: @unchecked Sendable { ... }
}

// INCORRECT - unconditional Sendable
extension Reference.Indirect: @unchecked Sendable {}
```

### [REF-003] Transfer Pattern

**Statement**: One-shot ownership transfer MUST use Cell + Token pattern.

```swift
let cell = Reference.Transfer.Cell(myValue)
let token = cell.token()  // consuming, creates Sendable token
spawnThread { let value = token.take() }  // consuming, retrieves value
```

### [REF-004] ~Copyable Value Support

**Statement**: All reference types MUST support `~Copyable` values.

```swift
struct Reference.Box<Value: ~Copyable>: ~Copyable { ... }
struct Reference.Indirect<Value: ~Copyable>: ~Copyable { ... }
```

---

## Type Hierarchy

```
Reference
├── .Box<Value>          // Immutable heap indirection
├── .Indirect<Value>     // Mutable heap indirection
│   └── .Unchecked       // Explicit unsafe Sendable
├── .Slot<Value>         // Move-semantic slot
└── .Transfer            // One-shot transfer
    ├── .Cell<Value>     // Source side
    └── .Token<Value>    // Receiver side (Sendable)
```

---

## Key Patterns

### Heap Indirection for Value Types

```swift
// Store large value type on heap
let boxed = Reference.Box(largeStruct)
// boxed is Copyable (shares reference)
```

### Mutable Indirection

```swift
var indirect = Reference.Indirect(mutableValue)
indirect.value.mutate()  // In-place mutation
```

### Cross-Thread Transfer

```swift
// Thread A
let cell = Reference.Transfer.Cell(resource)
let token = cell.token()

// Thread B (token is Sendable)
Task { @Sendable in
    let resource = token.take()  // consuming
    // resource is now owned by this task
}
```

### ~Copyable in Collections

```swift
// Wrap ~Copyable content for collection storage
final class Entry<T: Sendable>: @unchecked Sendable {
    enum State: ~Copyable {
        case pending
        case computing
        case completed(T)
    }
    var state: State
}
var cache: [Key: Entry<Value>] = [:]
```

---

## Cross-References

| Topic | Skill |
|-------|-------|
| Memory ownership | **memory** |
| Sendability tiers | **memory** [MEM-SEND-*] |
| ~Copyable patterns | **memory** [MEM-COPY-*] |

Full analysis: `Research/Reference Generic Placement Analysis.md`
