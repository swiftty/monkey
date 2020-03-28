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
        defer {
            readChar()
        }
        switch ch {
        case "=":
            return Token(type: .ASSIGN, literal: ch)

        case "+":
            return Token(type: .PLUS, literal: ch)

        case "{":
            return Token(type: .LBRACE, literal: ch)

        case "}":
            return Token(type: .RBRACE, literal: ch)

        case nil:
            return .init(type: .EOF, literal: "")

        default:
            return nil
        }
    }
}
