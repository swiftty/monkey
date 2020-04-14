public final class Integer: Object {
    public typealias Value = Int64
    public var value: Value

    public var type: ObjectType { .INTEGER }
    public func inspect() -> String { "\(value)" }

    init(value: Value) {
        self.value = value
    }
}
