import Foundation

/// usage: try SRJBindingsDecoder().decode(T.self, from: data)
/// => [T]
public class SRJBindingsDecoder {
    public init() {}

    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> [T] {
        let srj = try JSONDecoder().decode(SRJBindings.self, from: data)
        return try srj.results.bindings.map {
            return try T(from: _SRJBindingsDecoder(values: $0))
        }
    }
}

/// SPARQL 1.1 Query Results JSON Format (application/sparql-results+json)
/// https://www.w3.org/TR/sparql11-results-json/#json-result-object
/// Variable Binding Results
struct SRJBindings: Codable {
    public var head: Head
    public struct Head: Codable {
        var link: [String]?
        var vars: [String]
    }

    public var results: Results
    public struct Results: Codable {
        public var bindings: [[String: RDFTerm]]
    }
}

enum RDFTerm: Codable {
    case iri(IRI)
    case literal(string: String, lang: String?)
    case typed(value: String, datatype: String)
    case blank(String)

    private struct Raw: Codable {
        var type: String
        var value: String
        var lang: String?
        var datatype: String?

        enum CodingKeys: String, CodingKey {
            case type, value, lang = "xml:lang", datatype
        }
    }

    public init(from decoder: Decoder) throws {
        let raw = try Raw(from: decoder)
        switch raw.type {
        case "uri":
            self = .iri(.ref(IRIRef(value: raw.value)))
        case "literal":
            if let datatype = raw.datatype {
                self = .typed(value: raw.value, datatype: datatype)
            } else {
                self = .literal(string: raw.value, lang: raw.lang)
            }
        case "bnode":
            self = .blank(raw.value)
        default:
            let container = try? decoder.container(keyedBy: Raw.CodingKeys.self)
            let keys = container?.allKeys.map {$0.rawValue}.joined(separator: ", ") ?? String(describing: Raw.CodingKeys.self)
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "RDF Term type is not one of: \(keys)"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .iri(.ref(let ref)): try Raw(type: "uri", value: ref.value, lang: nil, datatype: nil).encode(to: encoder)
        case .iri: throw EncodingError.invalidValue(self, .init(codingPath: encoder.codingPath, debugDescription: ""))
        case .literal(string: let s, lang: let l): try Raw(type: "literal", value: s, lang: l, datatype: nil).encode(to: encoder)
        case .typed(value: let v, datatype: let t): try Raw(type: "literal", value: v, lang: nil, datatype: t).encode(to: encoder)
        case .blank(let v): try Raw(type: "bnode", value: v, lang: nil, datatype: nil).encode(to: encoder)
        }
    }
}

private class _SRJBindingsDecoder: Decoder {
    let values: [String: RDFTerm]

    var codingPath: [CodingKey] {return []}
    var userInfo: [CodingUserInfoKey: Any] {return [:]}

    init(values: [String: RDFTerm]) {
        self.values = values
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        return KeyedDecodingContainer(_SRJBindingsKeyedDecodingContainer(referencing: self))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, debugDescription: "should be decoded by key"))
    }
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.typeMismatch([Any].self, .init(codingPath: codingPath, debugDescription: "should be decoded by key"))
    }
}

private struct _SRJBindingsKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K

    var decoder: _SRJBindingsDecoder
    var codingPath: [CodingKey]

    init(referencing decoder: _SRJBindingsDecoder) {
        self.decoder = decoder
        self.codingPath = decoder.codingPath
    }

    var allKeys: [Key] {return decoder.values.keys.compactMap {Key(stringValue: $0)}}
    func contains(_ key: Key) -> Bool {return decoder.values.keys.contains(key.stringValue)}

    func decodeNil(forKey key: Key) throws -> Bool {
        return decoder.values[key.stringValue] == nil
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        guard let value = try decodeIfPresent(type, forKey: key) else { throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "")) }
        return value
    }

    func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return Bool(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .iri(.ref(let ref))?: return ref.value
        case .literal(string: let v, lang: _)?: return v
        case .typed(value: let v, datatype: _)?: return v
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return Int(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return Int8(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return Int16(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return Int32(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return Int64(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return UInt(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return UInt8(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return UInt16(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return UInt32(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return UInt64(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return Float(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        switch decoder.values[key.stringValue] {
        case nil: return nil
        case .typed(value: let v, datatype: _)?: return Double(v) // TODO: typecheck
        default: throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: ""))
        }
    }

    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "cannot parse generic types"))
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "cannot nest"))
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "cannot nest"))
    }

    func superDecoder() throws -> Decoder {
        throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "cannot nest"))
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "cannot nest"))
    }
}
