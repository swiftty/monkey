public struct Integer: Object {
    public var value: Int64

    public var type: ObjectType { .INTEGER }
    public func inspect() -> String { "\(value)" }
}
