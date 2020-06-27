import XCTest

struct ExpressionInput<Expected> {
    let input: String
    let expected: Expected
    let file: StaticString
    let line: UInt

    init(_ input: String, _ expected: Expected, file: StaticString = #filePath, line: UInt = #line) {
        self.input = input
        self.expected = expected
        self.file = file
        self.line = line
    }
}
