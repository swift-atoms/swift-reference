import Reference_Primitives
import Testing

extension Reference {
    @Suite struct Tests {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Reference.Tests.Unit {
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
