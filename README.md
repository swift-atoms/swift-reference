# Reference

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Non-owning reference values for Swift: weak and unowned wrappers plus explicit,
auditable sendability opt-ins.

## Quick Start

```swift
import Reference

final class Node: Sendable {
    let name: String

    init(name: String) {
        self.name = name
    }
}

let node = Node(name: "root")
let weak = Reference.Weak(node)
let unowned = Reference.Unowned(node)

weak.value?.name
unowned.value.name
```

`Reference.Unowned.Sendable.Checked` requires a `Sendable` object.
`Reference.Unowned.Sendable.Unchecked` and
`Reference.Sendability.Unchecked` are explicit escape hatches when the caller
must assert safety. The generic unchecked wrapper also accepts move-only values.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-atoms/swift-reference.git", branch: "main")
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

The package uses Swift tools 6.4 and declares Apple platform version 27.

## Products

| Product | Purpose |
|---------|---------|
| `Reference` | Foundation-free reference and sendability values. |
| `Reference Standard Library Integration` | Standard-library integration surface. |
| `Reference Apple Foundation Integration` | Apple Foundation integration and the package's only Foundation dependency. |

The package has no external dependencies. Under Embedded Swift, object-backed
weak and unowned wrappers are excluded with `hasFeature(Embedded)`; the
Foundation-free `Reference.Sendability.Unchecked` value remains available.

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
