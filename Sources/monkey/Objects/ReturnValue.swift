public final class ReturnValue: Object {
    public var value: Object

    public var type: ObjectType { .RETURN_VALUE }
    public func inspect() -> String { value.inspect() }

    init(value: Object) {
        self.value = value
    }
}
