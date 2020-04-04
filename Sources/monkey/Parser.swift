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

private let precedences = [
    TokenType.EQ: Precedence.EQUALS,
    .NOT_EQ: .EQUALS,
    .LT: .LESSGREATER,
    .GT: .LESSGREATER,
    .PLUS: .SUM,
    .MINUS: .SUM,
    .SLASH: .PRODUCT,
    .ASTERISK: .PRODUCT
]

// MARK: - Parser -
public struct Parser {
    typealias PrefixParser = (inout Parser) -> Expression?
    typealias InfixParser = (inout Parser, Expression?) -> Expression?

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
        registerPrefix(parseBooleanLiteral(), to: .TRUE)
        registerPrefix(parseBooleanLiteral(), to: .FALSE)
        registerPrefix(parseIntegerLiteral(), to: .INT)
        registerPrefix(parsePrefixExpression(), to: .BANG)
        registerPrefix(parsePrefixExpression(), to: .MINUS)
        registerPrefix(parseGroupedExpression(), to: .LPAREN)

        registerInfix(parseInfixExpression(), to: .PLUS)
        registerInfix(parseInfixExpression(), to: .MINUS)
        registerInfix(parseInfixExpression(), to: .SLASH)
        registerInfix(parseInfixExpression(), to: .ASTERISK)
        registerInfix(parseInfixExpression(), to: .EQ)
        registerInfix(parseInfixExpression(), to: .NOT_EQ)
        registerInfix(parseInfixExpression(), to: .LT)
        registerInfix(parseInfixExpression(), to: .GT)
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

    private func parseBooleanLiteral() -> PrefixParser {
        return {
            BooleanLiteral(token: $0.currToken, value: $0.currToken(is: .TRUE))
        }
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
            guard let right = $0.parseExpression(.PREFIX) else { return nil }
            return PrefixExpression(token: token, operator: token.literal, right: right)
        }
    }

    private func parseGroupedExpression() -> PrefixParser {
        return {
            $0.nextToken()
            guard let exp = $0.parseExpression(.LOWEST) else { return nil }
            guard $0.expectPeek(.RPAREN) else { return nil }
            return exp
        }
    }

    private func parseInfixExpression() -> InfixParser {
        return { p, left in
            guard let left = left else { return nil }
            let token = p.currToken
            let precedence = p.currPrecedence()
            p.nextToken()
            guard let right = p.parseExpression(precedence) else { return nil }
            return InfixExpression(token: token, left: left, operator: token.literal, right: right)
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

    private func peekPrecedence() -> Precedence {
        precedences[peekToken.type] ?? .LOWEST
    }

    private func currPrecedence() -> Precedence {
        precedences[currToken.type] ?? .LOWEST
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
        guard let prefix = prefixParseFns[currToken.type] else {
            noPrefixParseFnError(currToken.type)
            return nil
        }

        var left = prefix(&self)
        while !peekToken(is: .SEMICOLON), precedence < peekPrecedence() {
            guard let infix = infixParseFns[peekToken.type] else {
                return left
            }
            nextToken()
            left = infix(&self, left)
        }
        return left
    }
}

extension Parser {
    private mutating func parseExpressionStatement() -> Statement? {
        defer {
            if peekToken(is: .SEMICOLON) {
                nextToken()
            }
        }
        guard let exp = parseExpression(.LOWEST) else { return nil }
        return ExpressionStatement(token: currToken, expression: exp)
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
