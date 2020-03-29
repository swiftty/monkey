import TextScanner

public struct Lexer {
    private var scanner: TextScanner
    public private(set) var ch: Character?

    public init(_ input: String) {
        scanner = TextScanner(input)
        readChar()
    }

    public mutating func readChar() {
        ch = scanner.next()
    }

    public mutating func nextToken() -> Token? {

        skipWhitespace()

        let token: Token?
        switch ch {
        case "=":
            token = Token(type: .ASSIGN, literal: ch)

        case "+":
            token = Token(type: .PLUS, literal: ch)

        case ",":
            token = Token(type: .COMMA, literal: ch)

        case ";":
            token = Token(type: .SEMICOLON, literal: ch)

        case "(":
            token = Token(type: .LPAREN, literal: ch)

        case ")":
            token = Token(type: .RPAREN, literal: ch)

        case "{":
            token = Token(type: .LBRACE, literal: ch)

        case "}":
            token = Token(type: .RBRACE, literal: ch)

        case nil:
            token = Token(type: .EOF, literal: "")

        case let ch? where ch.isLetter:
            let literal = readIdentifier()
            return Token(type: .lookupIdent(literal), literal: literal)

        case let ch? where ch.isDigit:
            return Token(type: .INT, literal: readNumber())

        case let ch?:
            token = Token(type: .ILLEGAL, literal: ch)
        }

        readChar()
        return token
    }

    private mutating func skipWhitespace() {
        while ch?.isWhitespace ?? false {
            readChar()
        }
    }

    private mutating func readIdentifier() -> String {
        readLiteral(where: \.isLetterOrNumber)
    }

    private mutating func readNumber() -> String {
        readLiteral(where: \.isDigit)
    }

    private mutating func readLiteral(where cond: (Character) -> Bool) -> String {
        var str: [Character] = []
        while let ch = ch, cond(ch) {
            str.append(ch)
            readChar()
        }
        return String(str)
    }
}

private extension Character {
    var isDigit: Bool {
        return ("0"..."9").contains(self)
    }

    var isLetter: Bool {
        return ("a"..."z").contains(self)
            || ("A"..."Z").contains(self)
            || "_" == self
    }

    var isLetterOrNumber: Bool {
        return isLetter || isDigit
    }
}
