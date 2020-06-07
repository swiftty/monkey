public final class Hash: Object {
    public typealias Pairs = [AnyHashable: (key: Object, value: Object)]
    public var pairs: Pairs

    public var type: ObjectType { .HASH }
    public func inspect() -> String {
        var buffer = ""
        buffer += "{"
        buffer += pairs.values
            .map { "\($0.key.inspect()): \($0.value.inspect())" }
            .joined(separator: ", ")
        buffer += "}"
        return buffer
    }

    init(pairs: Pairs) {
        self.pairs = pairs
    }
}
