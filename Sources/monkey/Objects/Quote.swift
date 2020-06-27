public final class Quote: Object {
    public var type: ObjectType { .QUOTE }
    public func inspect() -> String { "QUOTE(\(node))" }

    public var node: Node

    init(node: Node) {
        self.node = node
    }
}
