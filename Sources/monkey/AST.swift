
public protocol Node {
    func tokenLiteral() -> String
}

public protocol Statement: Node {}

public protocol Expression: Node {}


public struct Program {
    var statements: [Statement]

    public func tokenLiteral() -> String? {
        statements.first?.tokenLiteral()
    }
}

public struct LetStatement: Statement {
    public var token: Token
    public var name: Identifier
    public var value: Expression?

    public func tokenLiteral() -> String { token.literal }
}


public struct Identifier: Expression {
    public var token: Token
    public var value: String

    public func tokenLiteral() -> String { token.literal }
}

public struct ReturnStatement: Statement {
    public var token: Token
    public var returnValue: Expression

    public func tokenLiteral() -> String { token.literal }
}
