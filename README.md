# swift-reference

Use this package to hold a class instance without keeping it alive, for example a back-pointer to a parent or delegate, or to carry a value across a concurrency boundary through an explicit, greppable assertion of sendability. Start from `Reference.Weak<Object>` when the object may legitimately disappear, `Reference.Unowned<Object>` when another owner is guaranteed to outlive the reference, and `Reference.Unowned.Sendable.Checked` or `Reference.Unowned.Sendable.Unchecked` when that unowned reference must cross isolation. To own a value, or to move ownership across a boundary, use the sibling package swift-ownership instead.

## Laws

- No wrapper retains its object. Storing an object in `Reference.Weak`, `Reference.Unowned`, `Reference.Unowned.Sendable.Checked` or `Reference.Unowned.Sendable.Unchecked` never extends its lifetime; a strong owner elsewhere decides when it is released.
- `Reference.Weak.value` reads `nil` once the last strong owner releases the object, and from then on stays `nil` until a new object is assigned.
- The unowned wrappers require the object to be alive for every read of `value`. Reading `value` after the object has been released traps; it never returns `nil` or stale memory.
- `Reference.Unowned.Sendable.Unchecked` and `Reference.Sendability.Unchecked` add no synchronisation. They only assert that the caller has made the transfer safe; the compiler checks nothing about the wrapped value. The `__unchecked:` argument label on `Reference.Sendability.Unchecked` exists so each such assertion can be found by searching for it.
- Under Embedded Swift only `Reference.Sendability.Unchecked` exists; the weak and unowned wrappers are compiled out.
