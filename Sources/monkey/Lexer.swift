
public struct Lexer {
    public var input: String
    public var position: Int = 0
    public var readPosition: Int = 0

    public var ch: Character?

    public init(_ input: String) {
        self.input = input
        readChar()
    }

    public mutating func readChar() {
        let index = input.index(input.startIndex, offsetBy: readPosition, limitedBy: input.endIndex)
            ?? input.endIndex
        if input.indices.contains(index) {
            ch = input[index]
        } else {
            ch = nil
        }
        position = readPosition
        readPosition += 1
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
