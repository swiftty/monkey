import Foundation
import monkey

private let PROMPT = ">> "

print("This is the Monky programming language!")
print("Feel free to type in commands")

repeat {
    print(PROMPT, terminator: "")
    guard let line = readLine() else {
        continue
    }

    var lexer = Lexer(line)
    while let token = lexer.nextToken(), token.type != .EOF {
        print(token)
    }
} while true
