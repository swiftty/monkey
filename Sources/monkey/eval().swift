private enum Const {
    static let TRUE = Boolean(value: true)
    static let FALSE = Boolean(value: false)
}

private extension Boolean {
    init(_ flag: Bool) {
        self = flag ? Const.TRUE : Const.FALSE
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
        return Boolean(node.value)

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
