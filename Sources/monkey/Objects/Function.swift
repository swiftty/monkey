public final class Function: Object {
    public var parameters: [Identifier]
    public var body: BlockStatement
    public var env: Environment

    public var type: ObjectType { .FUNCTION }
    public func inspect() -> String {
        var buffer = ""
        buffer += "fn("
        buffer += parameters.map(\.description).joined()
        buffer += ") {\n"
        buffer += body.description
        buffer += "\n}"
        return buffer
    }

    init(parameters: [Identifier], body: BlockStatement, env: Environment) {
        self.parameters = parameters
        self.body = body
        self.env = env
    }
}
