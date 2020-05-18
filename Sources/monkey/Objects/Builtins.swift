public final class Builtin: Object {
    public typealias Function = ([Object?]) -> Object

    public var fn: Function

    public var type: ObjectType { .BUILTIN }
    public func inspect() -> String { "builtin function" }

    init(_ fn: @escaping Function) {
        self.fn = fn
    }
}
