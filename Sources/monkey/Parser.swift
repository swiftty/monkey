private enum Precedence: Int, Comparable {
    case LOWEST
    case EQUALS
    case LESSGREATER
    case SUM
    case PRODUCT
    case PREFIX
    case CALL

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}


public struct Parser {
    typealias PrefixParser = (inout Parser) -> Expression?
    typealias InfixParser = (inout Parser, Expression) -> Expression

    public var lexer: Lexer

    public private(set) var errors: [String] = []

    var currToken: Token
    var peekToken: Token

    var prefixParseFns: [TokenType: PrefixParser] = [:]
    var infixParseFns: [TokenType: InfixParser] = [:]

    public init(lexer l: Lexer) {
        lexer = l
        currToken = lexer.nextToken()
        peekToken = lexer.nextToken()

        registerPrefix(parseIdentifier(), to: .IDENT)
        registerPrefix(parseIntegerLiteral(), to: .INT)
        registerPrefix(parsePrefixExpression(), to: .BANG)
        registerPrefix(parsePrefixExpression(), to: .MINUS)
    }

    public mutating func nextToken() {
        currToken = peekToken
        peekToken = lexer.nextToken()
    }

    public mutating func parseProgram() -> Program {
        var program = Program(statements: [])

        while currToken.type != .EOF {
            if let stmt = parseStatement() {
                program.statements.append(stmt)
            }
            nextToken()
        }

        return program
    }

    private mutating func registerPrefix(_ fn: @escaping PrefixParser, to type: TokenType) {
        prefixParseFns[type] = fn
    }

    private mutating func registerInfix(_ fn: @escaping InfixParser, to type: TokenType) {
        infixParseFns[type] = fn
    }

    private func parseIdentifier() -> PrefixParser {
        return { Identifier(token: $0.currToken, value: $0.currToken.literal) }
    }

    private func parseIntegerLiteral() -> PrefixParser {
        return {
            guard let value = Int64($0.currToken.literal) else {
                $0.errors.append("could not parse \($0.currToken.literal) as integer")
                return nil
            }
            return IntegerLiteral(token: $0.currToken, value: value)
        }
    }

    private func parsePrefixExpression() -> PrefixParser {
        return {
            let token = $0.currToken
            $0.nextToken()
            return PrefixExpression(token: token,
                                    operator: token.literal,
                                    right: $0.parseExpression(.PREFIX))
        }
    }
}

extension Parser {
    private mutating func peekError(_ type: TokenType) {
        let message = "expected next token to be \(type). got \(peekToken.type) insted"
        errors.append(message)
    }

    private mutating func noPrefixParseFnError(_ type: TokenType) {
        errors.append("no prefix parse function for `\(type)` found")
    }

    private mutating func parseStatement() -> Statement? {
        switch currToken.type {
        case .LET: return parseLetStatement()
        case .RETURN: return parseReturnStatement()
        default: return parseExpressionStatement()
        }
    }

    private func currToken(is type: TokenType) -> Bool {
        currToken.type == type
    }

    private func peekToken(is type: TokenType) -> Bool {
        peekToken.type == type
    }

    private mutating func expectPeek(_ type: TokenType) -> Bool {
        if peekToken(is: type) {
            nextToken()
            return true
        } else {
            peekError(type)
            return false
        }
    }
}

extension Parser {
    private mutating func parseExpression(_ precedence: Precedence) -> Expression? {
        if let prefix = prefixParseFns[currToken.type] {
            return prefix(&self)
        }
        noPrefixParseFnError(currToken.type)
        return nil
    }
}

extension Parser {
    private mutating func parseExpressionStatement() -> Statement? {
        let stmt = ExpressionStatement(token: currToken, expression: parseExpression(.LOWEST))

        if peekToken(is: .SEMICOLON) {
            nextToken()
        }

        return stmt
    }

    private mutating func parseLetStatement() -> Statement? {
        let token = currToken
        if !expectPeek(.IDENT) {
            return nil
        }

        let name = Identifier(token: currToken, value: currToken.literal)
        if !expectPeek(.ASSIGN) {
            return nil
        }

        while !currToken(is: .SEMICOLON) {
            nextToken()
        }

        return LetStatement(token: token, name: name, value: nil)
    }

    private mutating func parseReturnStatement() -> Statement? {
        let stmt = ReturnStatement(token: currToken, returnValue: nil)

        nextToken()

        while !currToken(is: .SEMICOLON) {
            nextToken()
        }

        return stmt
    }
}
