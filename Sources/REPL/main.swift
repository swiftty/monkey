import Foundation
import monkey

private let PROMPT = ">> "

print("This is the Monky programming language!")
print("Feel free to type in commands")

var env = Environment()

repeat {
    print(PROMPT, terminator: "")
    guard let line = readLine() else {
        continue
    }

    var parser = Parser(lexer: .init(line))

    let program = parser.parseProgram()
    if !parser.errors.isEmpty {
        for msg in parser.errors {
            print("\t", msg)
        }
        continue
    }

    let evaluated = eval(program, env: &env)
    print(evaluated.inspect())

} while true
