
public protocol Node: CustomStringConvertible {
    func tokenLiteral() -> String
}

public protocol Statement: Node {}

public protocol Expression: Node {}


public struct Program: CustomStringConvertible {
    var statements: [Statement]

    public var description: String {
        statements.map(\.description).joined()
    }

    public func tokenLiteral() -> String? {
        statements.first?.tokenLiteral()
    }
}

public struct Identifier: Expression {
    public var token: Token
    public var value: String

    public var description: String {
        value
    }

    public func tokenLiteral() -> String { token.literal }
}

public struct BooleanLiteral: Expression {
    public var token: Token
    public var value: Bool

    public var description: String {
        token.literal
    }

    public func tokenLiteral() -> String { token.literal }
}

public struct IntegerLiteral: Expression {
    public var token: Token
    public var value: Int64

    public var description: String {
        token.literal
    }

    public func tokenLiteral() -> String { token.literal }
}

public struct FunctionLiteral: Expression {
    public var token: Token
    public var parameters: [Identifier]
    public var body: BlockStatement

    public var description: String {
        var buffer = ""
        buffer += tokenLiteral()
        buffer += "("
        buffer += parameters.map(\.description).joined()
        buffer += ") "
        buffer += body.description
        return buffer
    }

    public func tokenLiteral() -> String { token.literal }
}

public struct PrefixExpression: Expression {
    public var token: Token
    public var `operator`: String
    public var right: Expression

    public var description: String {
        var buffer = "("
        buffer += `operator`
        buffer += right.description
        buffer += ")"
        return buffer
    }

    public func tokenLiteral() -> String { token.literal }
}

public struct InfixExpression: Expression {
    public var token: Token
    public var left: Expression
    public var `operator`: String
    public var right: Expression

    public var description: String {
        var buffer = "("
        buffer += left.description
        buffer += " \(`operator`) "
        buffer += right.description
        buffer += ")"
        return buffer
    }

    public func tokenLiteral() -> String { token.literal }
}

public struct IfExpression: Expression {
    public var token: Token
    public var condition: Expression
    public var consequence: BlockStatement
    public var alternative: BlockStatement?

    public var description: String {
        var buffer = ""
        buffer += "if"
        buffer += condition.description
        buffer += " "
        buffer += consequence.description
        if let alt = alternative {
            buffer += "else "
            buffer += alt.description
        }
        return buffer
    }

    public func tokenLiteral() -> String { token.literal }
}

public struct CallExpression: Expression {
    public var token: Token
    public var function: Expression
    public var arguments: [Expression]

    public var description: String {
        var buffer = ""
        buffer += function.description
        buffer += "("
        buffer += arguments.map(\.description).joined(separator: ", ")
        buffer += ")"
        return buffer
    }

    public func tokenLiteral() -> String { token.literal }
}


// MARK: - Statement -
public struct ExpressionStatement: Statement {
    public var token: Token
    public var expression: Expression

    public var description: String { expression.description }

    public func tokenLiteral() -> String { token.literal }
}

public struct LetStatement: Statement {
    public var token: Token
    public var name: Identifier
    public var value: Expression?

    public var description: String {
        var buffer = ""
        buffer += tokenLiteral() + " "
        buffer += name.description
        buffer += " = "
        if let value = value {
            buffer += value.description
        }
        buffer += ";"
        return buffer
    }

    public func tokenLiteral() -> String { token.literal }
}

public struct ReturnStatement: Statement {
    public var token: Token
    public var returnValue: Expression?

    public var description: String {
        var buffer = ""
        buffer += tokenLiteral() + " "
        if let returnValue = returnValue {
            buffer += returnValue.description
        }
        buffer += ";"
        return buffer
    }

    public func tokenLiteral() -> String { token.literal }
}

public struct BlockStatement: Statement {
    public var token: Token
    public var statements: [Statement]

    public var description: String {
        statements.map(\.description).joined()
    }

    public func tokenLiteral() -> String { token.literal }
}
