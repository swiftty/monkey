public final class Integer: Object, Hashable_ {
    public typealias Value = Int64
    public var value: Value

    public var type: ObjectType { .INTEGER }
    public func inspect() -> String { "\(value)" }
    public func hashKey() -> AnyHashable { value }

    init(value: Value) {
        self.value = value
    }
}
