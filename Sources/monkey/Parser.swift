
public struct Parser {
    public var lexer: Lexer

    public var currToken: Token
    public var peekToken: Token

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

    private mutating func parseStatement() -> Statement? {
        return currToken.type == .LET
            ? parseLetStatement()
            : nil
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
            return false
        }
    }
}
