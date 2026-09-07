import Reference
import Testing

extension Reference {
    @Suite struct `Behavior contracts` {
        @Suite struct `Unit behavior` {}
        @Suite struct `Edge Case` {}
        @Suite struct `Integration behavior` {}
    }
}

extension Reference.`Behavior contracts`.`Unit behavior` {
    @Test func `weak reference accepts nil`() {
        final class Node: Sendable {}
        let weak = Reference.Weak<Node>(nil)
        #expect(weak.value == nil)
    }

    @Test func `unowned reference stores value`() {
        final class Node: Sendable {
            let name: String
            init(name: String) { self.name = name }
        }
        let node = Node(name: "test")
        let ref = Reference.Unowned(node)
        #expect(ref.value.name == "test")
    }

    @Test func `checked sendable unowned stores value`() {
        final class Safe: Sendable {
            let id: Int
            init(id: Int) { self.id = id }
        }
        let node = Safe(id: 1)
        let ref = Reference.Unowned<Safe>.Sendable.Checked(node)
        #expect(ref.value.id == 1)
    }

    @Test func `unchecked sendability wraps`() {

        let wrapped = Reference.Sendability.Unchecked(__unchecked: 42)
        #expect(wrapped.value == 42)
    }
}

@Suite
struct `Reference lifetime and sendability` {
    @Test
    func `weak references become nil when the final strong owner is released`() {
        final class Node: Sendable {}
        let weak: Reference.Weak<Node>
        do {
            let owner = Node()
            weak = Reference.Weak(owner)
            #expect(weak.value === owner)
            _fixLifetime(owner)
        }
        #expect(weak.value == nil)
    }

    @Test
    func `checked unowned references cross tasks while a strong owner remains alive`() async {
        final class Node: Sendable {
            let value = 42
        }
        let owner = Node()
        let reference = Reference.Unowned<Node>.Sendable.Checked(owner)
        let received = await Task.detached { reference.value.value }.value
        #expect(received == 42)
        _fixLifetime(owner)
    }

    @Test
    func `unchecked sendability can transfer a noncopyable value`() async {
        struct Payload: ~Copyable { let value: Int }
        let wrapped = Reference.Sendability.Unchecked(__unchecked: Payload(value: 42))
        func receive(_ value: consuming sending Reference.Sendability.Unchecked<Payload>) async -> Int {
            value.value.value
        }
        #expect(await receive(wrapped) == 42)
    }
}
