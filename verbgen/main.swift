import Foundation
import SwiftSparql

// FIXME: do not use build time #file and take as input
let projectDir = URL(fileURLWithPath: #file, isDirectory: false).deletingLastPathComponent().deletingLastPathComponent()
let vocabulariesDir = projectDir
    .appendingPathComponent("Example")
    .appendingPathComponent("Vocabularies")
let turtleFile = vocabulariesDir.appendingPathComponent("imas-schema.ttl")
let turtleDoc = try! TurtleDoc(String(contentsOf: turtleFile))
//        NSLog("%@", "turtleDoc = \(String(describing: turtleDoc))")
let subjects = turtleDoc.triples.compactMap {SubjectDescription($0)}

struct CamelIdentifier {
    var id: String
    init(raw: String) {
        id = raw.components(separatedBy: .init(charactersIn: ":-"))
            .map {($0.first?.uppercased() ?? "") + $0.dropFirst()}
            .joined()
    }
}

struct IRIBaseProvider {
    let name: PNameNS
    let iri: IRIRef

    var swiftCode: String {
        return """
        public enum \(CamelIdentifier(raw: name.value!).id + "Schema"): IRIBaseProvider {
            public static var base: IRIRef {return IRIRef(value: "\(iri.value)")}
        }
        """
    }
}

struct TripleBuilderStateRDFTypeBoundType {
    let type: CamelIdentifier
    let verbs: [String] // TODO: query ?s ?v ?o with ?s rdf:type typeName and lookup turtleDoc for labels & comments

    init?(subject: TurtleDoc.Subject, verbs: [String]) {
        switch subject {
        case .iri(let v): type = CamelIdentifier(raw: Serializer.serialize(v))
        default: return nil
        }
        self.verbs = verbs
    }

    var swiftCode: String {
        return """
        public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == \(type.id) {
        \(verbs.map {"    " + $0}.joined(separator: "\n\n"))
        }
        """
    }
}

let directives: [IRIBaseProvider] = turtleDoc.statements.compactMap {
    switch $0 {
    case .directive(.prefixID(let name, let iri)): return IRIBaseProvider(name: name, iri: iri)
    case .directive, .triple: return nil
    }
}

let classes = subjects.filter {
    switch $0.a {
    case .prefixedName(.ln((PNameNS(value: "rdfs"), "Class")))?: return true
    default: return false
    }
}

let extensions = classes.compactMap {
    TripleBuilderStateRDFTypeBoundType(
        subject: $0.subject,
        verbs: ["verb1", "verb2"])
}

let swiftCodes = directives.map {$0.swiftCode} + extensions.map {$0.swiftCode}
// print(swiftCodes.joined(separator: "\n\n"))
print(swiftCodes.joined(separator: "\n\n"))

