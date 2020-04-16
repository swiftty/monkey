public final class ERROR: Object {
    public var message: String

    public var type: ObjectType { .ERROR }
    public func inspect() -> String { "ERROR: \(message)" }

    init(message: String) {
        self.message = message
    }
}
