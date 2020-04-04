import XCTest
@testable import monkey

final class LexerTests: XCTestCase {
    func testNextToken() {
        let input = """
        let five = 5;
        let ten = 10;

        let add = fn(x, y) {
            x + y;
        };

        let result = add(five, ten);
        !-/*5;
        5 < 10 > 5;

        if (5 < 10) {
            return true;
        } else {
            return false;
        }

        10 == 10;
        10 != 9;
        """

        let tests: [(expectedType: TokenType, expectedLiteral: String)] = [
            (.LET, "let"),
            (.IDENT, "five"),
            (.ASSIGN, "="),
            (.INT, "5"),
            (.SEMICOLON, ";"),
            (.LET, "let"),
            (.IDENT, "ten"),
            (.ASSIGN, "="),
            (.INT, "10"),
            (.SEMICOLON, ";"),
            (.LET, "let"),
            (.IDENT, "add"),
            (.ASSIGN, "="),
            (.FUNCTION, "fn"),
            (.LPAREN, "("),
            (.IDENT, "x"),
            (.COMMA, ","),
            (.IDENT, "y"),
            (.RPAREN, ")"),
            (.LBRACE, "{"),
            (.IDENT, "x"),
            (.PLUS, "+"),
            (.IDENT, "y"),
            (.SEMICOLON, ";"),
            (.RBRACE, "}"),
            (.SEMICOLON, ";"),
            (.LET, "let"),
            (.IDENT, "result"),
            (.ASSIGN, "="),
            (.IDENT, "add"),
            (.LPAREN, "("),
            (.IDENT, "five"),
            (.COMMA, ","),
            (.IDENT, "ten"),
            (.RPAREN, ")"),
            (.SEMICOLON, ";"),
            (.BANG, "!"),
            (.MINUS, "-"),
            (.SLASH, "/"),
            (.ASTERISK, "*"),
            (.INT, "5"),
            (.SEMICOLON, ";"),
            (.INT, "5"),
            (.LT, "<"),
            (.INT, "10"),
            (.GT, ">"),
            (.INT, "5"),
            (.SEMICOLON, ";"),
            (.IF, "if"),
            (.LPAREN, "("),
            (.INT, "5"),
            (.LT, "<"),
            (.INT, "10"),
            (.RPAREN, ")"),
            (.LBRACE, "{"),
            (.RETURN, "return"),
            (.TRUE, "true"),
            (.SEMICOLON, ";"),
            (.RBRACE, "}"),
            (.ELSE, "else"),
            (.LBRACE, "{"),
            (.RETURN, "return"),
            (.FALSE, "false"),
            (.SEMICOLON, ";"),
            (.RBRACE, "}"),
            (.INT, "10"),
            (.EQ, "=="),
            (.INT, "10"),
            (.SEMICOLON, ";"),
            (.INT, "10"),
            (.NOT_EQ, "!="),
            (.INT, "9"),
            (.SEMICOLON, ";"),
            (.EOF, "")
        ]

        var lexer = Lexer(input)

        for (i, t) in tests.enumerated() {
            let tok = lexer.nextToken()

            if tok.type != t.expectedType {
                XCTFail("tests[\(i)] - tokentype wrong.expected=\(t.expectedType), got=\(tok.type)")
            }

            if tok.literal != t.expectedLiteral {
                XCTFail("tests[\(i)] - literal wrong.expected=\(t.expectedLiteral), got=\(tok.literal)")
            }
        }
    }
}
