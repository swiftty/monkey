public final class String_: Object {
    public typealias Value = String
    public var value: Value

    public var type: ObjectType { .STRING }
    public func inspect() -> String { value }

    init(value: Value) {
        self.value = value
    }
}
