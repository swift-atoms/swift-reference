import Testing
import Reference_Primitives

@Suite struct ReferencePrimitivesTests {
    @Test func weakReferenceAcceptsNil() {
        final class Node: Sendable { }
        let weak = Reference.Weak<Node>(nil)
        #expect(weak.value == nil)
    }

    @Test func unownedReferenceStoresValue() {
        final class Node: Sendable {
            let name: String
            init(name: String) { self.name = name }
        }
        let node = Node(name: "test")
        let ref = Reference.Unowned(node)
        #expect(ref.value.name == "test")
    }

    @Test func checkedSendableUnownedStoresValue() {
        final class SafeNode: Sendable {
            let id: Int
            init(id: Int) { self.id = id }
        }
        let node = SafeNode(id: 1)
        let ref = Reference.Unowned<SafeNode>.Sendable.Checked(node)
        #expect(ref.value.id == 1)
    }

    @Test func uncheckedSendabilityWraps() {
        let wrapped = Reference.Sendability.Unchecked(__unchecked: 42)
        #expect(wrapped.value == 42)
    }
}
