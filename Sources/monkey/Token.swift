import Foundation

public struct TokenType: RawRepresentable {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct Token {
    public var type: TokenType
    public var literal: String

    public init(type: TokenType, literal: String) {
        self.type = type
        self.literal = literal
    }

    public init?(type: TokenType, literal: Character?) {
        guard let literal = literal else { return nil }
        self.type = type
        self.literal = String(literal)
    }
}

extension TokenType {
    public static let ILLEGAL = TokenType(rawValue: "ILLEGAL")
    public static let EOF = TokenType(rawValue: "EOF")

    public static let IDENT = TokenType(rawValue: "IDENT")
    public static let INT = TokenType(rawValue: "INT")

    public static let ASSIGN = TokenType(rawValue: "=")
    public static let PLUS = TokenType(rawValue: "+")

    public static let COMMA = TokenType(rawValue: ",")
    public static let SEMICOLON = TokenType(rawValue: ";")

    public static let LPAREN = TokenType(rawValue: "(")
    public static let RPAREN = TokenType(rawValue: ")")
    public static let LBRACE = TokenType(rawValue: "{")
    public static let RBRACE = TokenType(rawValue: "}")

    public static let FUNCTION = TokenType(rawValue: "FUNCTION")
    public static let LET = TokenType(rawValue: "LET")
}
