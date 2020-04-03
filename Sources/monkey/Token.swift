import Foundation

public struct TokenType: RawRepresentable, Equatable, Hashable {
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

    public init?(type: TokenType, literal: Character?, _ trailing: Character?...) {
        guard case let str = ([literal] + trailing).compactMap({ $0 }), !str.isEmpty else { return nil }
        self.type = type
        self.literal = String(str)
    }
}

extension TokenType {
    public static let ILLEGAL = TokenType(rawValue: "ILLEGAL")
    public static let EOF = TokenType(rawValue: "EOF")

    public static let IDENT = TokenType(rawValue: "IDENT")
    public static let INT = TokenType(rawValue: "INT")

    public static let ASSIGN = TokenType(rawValue: "=")
    public static let PLUS = TokenType(rawValue: "+")
    public static let MINUS = TokenType(rawValue: "-")
    public static let BANG = TokenType(rawValue: "!")
    public static let ASTERISK = TokenType(rawValue: "*")
    public static let SLASH = TokenType(rawValue: "/")

    public static let EQ = TokenType(rawValue: "==")
    public static let NOT_EQ = TokenType(rawValue: "!=")

    public static let LT = TokenType(rawValue: "<")
    public static let GT = TokenType(rawValue: ">")

    public static let COMMA = TokenType(rawValue: ",")
    public static let SEMICOLON = TokenType(rawValue: ";")

    public static let LPAREN = TokenType(rawValue: "(")
    public static let RPAREN = TokenType(rawValue: ")")
    public static let LBRACE = TokenType(rawValue: "{")
    public static let RBRACE = TokenType(rawValue: "}")

    public static let FUNCTION = TokenType(rawValue: "FUNCTION")
    public static let LET = TokenType(rawValue: "LET")
    public static let TRUE = TokenType(rawValue: "TRUE")
    public static let FALSE = TokenType(rawValue: "FALSE")
    public static let IF = TokenType(rawValue: "IF")
    public static let ELSE = TokenType(rawValue: "ELSE")
    public static let RETURN = TokenType(rawValue: "RETURN")
}

extension TokenType {
    public static func lookupIdent(_ ident: String) -> TokenType {
        keywords[ident] ?? .IDENT
    }

    private static let keywords: [String: TokenType] = [
        "fn": .FUNCTION,
        "let": .LET,
        "true": .TRUE,
        "false": .FALSE,
        "if": .IF,
        "else": .ELSE,
        "return": .RETURN
    ]
}
