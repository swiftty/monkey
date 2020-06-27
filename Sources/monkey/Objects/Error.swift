public final class ERROR: Object, CustomStringConvertible {
    public var message: String

    public var type: ObjectType { .ERROR }
    public func inspect() -> String { "ERROR: \(message)" }
    public var description: String { inspect() }

    init(message: String) {
        self.message = message
    }
}
