public final class Boolean: Object {
    public var value: Bool

    public var type: ObjectType { .BOOLEAN }
    public func inspect() -> String { "\(value)" }

    init(value: Bool) {
        self.value = value
    }
}
