public final class Array_: Object {
    public var elements: [Object]

    public var type: ObjectType { .ARRAY }
    public func inspect() -> String {
        var buffer = ""
        buffer += "["
        buffer += elements.map { $0.inspect() }.joined(separator: ", ")
        buffer += "]"
        return buffer
    }

    init(elements: [Object]) {
        self.elements = elements
    }
}
