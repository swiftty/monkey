public final class Boolean: Object, Hashable_ {
    public var value: Bool

    public var type: ObjectType { .BOOLEAN }
    public func inspect() -> String { "\(value)" }
    public func hashKey() -> AnyHashable { value }

    init(value: Bool) {
        self.value = value
    }
}
