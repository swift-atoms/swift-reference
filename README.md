# Reference

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Non-owning reference types for Swift — weak and unowned wrappers, plus auditable `Sendable` escape hatches, with zero platform dependencies.

---

## Quick Start

`Reference` is a namespace for types that refer to objects **without owning them**. They do not participate in the lifetime of what they point at, which makes them the building blocks for back-references and parent pointers that would otherwise create retain cycles.

```swift
import Reference

final class Node: Sendable { let name: String; init(name: String) { self.name = name } }
let node = Node(name: "root")

// A zeroing weak reference: `value` becomes nil when the object is deallocated.
let weak = Reference.Weak(node)
print(weak.value?.name)   // Optional("root")

// An unowned reference: non-optional, for parent pointers that outlive the child.
let parent = Reference.Unowned(node)
print(parent.value.name)  // "root"
```

`Reference.Weak` is `Sendable` whenever its `Object` is `Sendable`. `Reference.Unowned` is deliberately **not** `Sendable`; to cross an isolation boundary, opt in explicitly with `Reference.Unowned.Sendable.Checked` (compiler-verified, requires `Object: Sendable`) or `Reference.Unowned.Sendable.Unchecked` (an explicit, auditable assertion).

```swift
// Compiler-checked Sendable unowned reference.
let checked = Reference.Unowned<Node>.Sendable.Checked(node)

// An auditable escape hatch for values the compiler cannot prove Sendable.
let wrapped = Reference.Sendability.Unchecked(__unchecked: 42)
print(wrapped.value)      // 42
```

`Reference.Sendability.Unchecked` wraps any value—including non-copyable ones—as `@unchecked Sendable`. It provides no guarantees; it exists solely as a single, greppable site where you assert sendability the compiler cannot verify.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-molecules/swift-reference.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Reference", package: "swift-reference"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Two library products, zero external dependencies.

| Product | Target | Purpose |
|---------|--------|---------|
| `Reference` | `Sources/Reference/` | The `Reference` namespace: `Reference.Weak` (zeroing weak), `Reference.Unowned` (unsafe unowned) with `.Sendable.Checked` / `.Sendable.Unchecked` opt-ins, and `Reference.Sendability.Unchecked` (an auditable `@unchecked Sendable` wrapper). |
| `Reference Test Support` | `Tests/Support/` | Re-exports the main target for test consumers. |

For types that **own** their values—unique, shared, and slot ownership—import `Ownership`.

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |
| Swift Embedded | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
