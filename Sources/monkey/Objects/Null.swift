public struct Null: Object {
    public var type: ObjectType { .NULL }
    public func inspect() -> String { "null" }
}
