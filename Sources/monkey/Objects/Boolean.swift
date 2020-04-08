public struct Boolean: Object {
    public var value: Bool

    public var type: ObjectType { .BOOLEAN }
    public func inspect() -> String { "\(value)" }
}
