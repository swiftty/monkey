
public struct Parser {
    public var lexer: Lexer

    public private(set) var errors: [String] = []

    var currToken: Token
    var peekToken: Token

    var prefixParseFns: [TokenType: () -> Expression] = [:]
    var infixParseFns: [TokenType: (Expression) -> Expression] = [:]

    public init(lexer l: Lexer) {
        lexer = l
        currToken = lexer.nextToken()
        peekToken = lexer.nextToken()
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

    private mutating func registerPrefix(_ fn: @escaping () -> Expression, to type: TokenType) {
        prefixParseFns[type] = fn
    }

    private mutating func registerInfix(_ fn: @escaping (Expression) -> Expression, to type: TokenType) {
        infixParseFns[type] = fn
    }
}

extension Parser {
    private mutating func peekError(_ type: TokenType) {
        let message = "expected next token to be \(type). got \(peekToken.type) insted"
        errors.append(message)
    }

    private mutating func parseStatement() -> Statement? {
        switch currToken.type {
        case .LET: return parseLetStatement()
        case .RETURN: return parseReturnStatement()
        default: return nil
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
