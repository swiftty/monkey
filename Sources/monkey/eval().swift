private enum Const {
    static let NULL = Null()
    static let TRUE = Boolean(value: true)
    static let FALSE = Boolean(value: false)
}

private extension Boolean {
    static func from(native flag: Bool) -> Boolean {
        flag ? Const.TRUE : Const.FALSE
    }

    func toggled() -> Boolean {
        value ? Const.FALSE : Const.TRUE
    }
}

public func eval(_ node: Node) -> Object? {
    switch node {
    case let node as Program:
        return evalStatements(node.statements)

    case let node as ExpressionStatement:
        return eval(node.expression)

    case let node as IntegerLiteral:
        return Integer(value: node.value)

    case let node as BooleanLiteral:
        return Boolean.from(native: node.value)

    case let node as PrefixExpression:
        return evalPrefixExpression(node.operator, eval(node.right))

    case let node as InfixExpression:
        return evalInfixExpression(node.operator, eval(node.left), eval(node.right))

    default:
        return nil
    }
}

// MARK: - private -
private func evalStatements(_ statements: [Statement]) -> Object? {
    var result: Object?
    for stmt in statements {
        result = eval(stmt)
    }
    return result
}

private func evalPrefixExpression(_ operator: String, _ right: Object?) -> Object? {
    switch `operator` {
    case "!":
        return evalBangOperatorExpression(right)

    case "-":
        return evalMinusPrefixOperatorExpression(right)

    default:
        return Const.NULL
    }
}

private func evalBangOperatorExpression(_ right: Object?) -> Object {
    switch right {
    case let bool as Boolean:
        return bool.toggled()

    case is Null:
        return Const.TRUE

    default:
        return Const.FALSE
    }
}

private func evalMinusPrefixOperatorExpression(_ right: Object?) -> Object {
    guard let right = right as? Integer else { return Const.NULL }
    return Integer(value: -right.value)
}

private func evalInfixExpression(_ operator: String, _ left: Object?, _ right: Object?) -> Object {
    switch (left, right) {
    case (let left as Integer, let right as Integer):
        return evalIntegerInfixExpression(`operator`, left, right)

    case (let left as Object, let right as Object) where `operator` == "==":
        return Boolean.from(native: left === right)

    case (let left as Object, let right as Object) where `operator` == "!=":
        return Boolean.from(native: left !== right)

    default:
        return Const.NULL
    }
}

private func evalIntegerInfixExpression(_ operator: String, _ left: Integer, _ right: Integer) -> Object {
    switch  `operator` {
    case "+":
        return Integer(value: left.value + right.value)

    case "-":
        return Integer(value: left.value - right.value)

    case "*":
        return Integer(value: left.value * right.value)

    case "/":
        return Integer(value: left.value / right.value)

    case "<":
        return Boolean.from(native: left.value < right.value)

    case ">":
        return Boolean.from(native: left.value > right.value)

    case "==":
        return Boolean.from(native: left.value == right.value)

    case "!=":
        return Boolean.from(native: left.value != right.value)

    default:
        return Const.NULL
    }
}
