import Foundation

public struct Response<T: Codable>: Codable {
    public var results: Results
    public struct Results: Codable {
        public var bindings: [T]
    }
}

public struct ResponseLiteral<T: Codable & ExpressibleByRDFTermLiteral>: Codable {
    public var value: T

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let value = try T(RDFTermLiteral: container.decode(String.self, forKey: .value)) else {
            throw ExpressibleByRDFTermLiteralError.mismatch(decoder.codingPath.last)
        }
        self.value = value
    }
}

public enum ExpressibleByRDFTermLiteralError: Error {
    case mismatch(CodingKey?)
}

public protocol ExpressibleByRDFTermLiteral {
    init?(RDFTermLiteral value: String)
}

extension String: ExpressibleByRDFTermLiteral {
    public init(RDFTermLiteral value: String) { self = value }
}

extension Int: ExpressibleByRDFTermLiteral {
    public init?(RDFTermLiteral value: String) {
        guard let value = Int(value) else { return nil }
        self = value
    }
}

extension Double: ExpressibleByRDFTermLiteral {
    public init?(RDFTermLiteral value: String) {
        guard let value = Double(value) else { return nil }
        self = value
    }
}
