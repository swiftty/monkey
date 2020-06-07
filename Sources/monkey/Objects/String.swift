public final class String_: Object, Hashable_ {
    public typealias Value = String
    public var value: Value

    public var type: ObjectType { .STRING }
    public func inspect() -> String { value }
    public func hashKey() -> AnyHashable { value }

    init(value: Value) {
        self.value = value
    }
}
