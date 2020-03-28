import XCTest
@testable import monkey

final class LexerTests: XCTestCase {
    func testNextToken() {
        let input = "=+(){},;"

        let tests: [(expectedType: TokenType, expectedLiteral: String)] = [
            (TokenType.ASSIGN, "="),
            (TokenType.PLUS, "+"),
            (TokenType.LPAREN, "("),
            (TokenType.RPAREN, ")"),
            (TokenType.LBRACE, "{"),
            (TokenType.RBRACE, "}"),
            (TokenType.COMMA, ","),
            (TokenType.SEMICOLON, ";"),
            (TokenType.EOF, "")
        ]

        var lexer = Lexer(input)

        for (i, t) in tests.enumerated() {
            guard let tok = lexer.nextToken() else {
                continue
            }
            if tok.type != t.expectedType {
                XCTFail("tests[\(i)] - tokentype wrong.expected=\(t.expectedType), got=\(tok.type)")
            }

            if tok.literal != t.expectedLiteral {
                XCTFail("tests[\(i)] - literal wrong.expected=\(t.expectedLiteral), got=\(tok.literal)")
            }
        }
    }

    static var allTests = [
        ("testNextToken", testNextToken),
    ]
}
