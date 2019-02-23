import Foundation
import SwiftSparql
import ReactiveSwift
import enum Result.NoError

// generate defined verbs with this endpoint
let endpoint = URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!
let turtleFilename = "imas-schema.ttl"

// FIXME: do not use build time #file and take as input
let projectDir = URL(fileURLWithPath: #file, isDirectory: false).deletingLastPathComponent().deletingLastPathComponent()
let vocabulariesDir = projectDir
    .appendingPathComponent("Example")
    .appendingPathComponent("Vocabularies")
let turtleFile = vocabulariesDir.appendingPathComponent(turtleFilename)
let turtleDoc = try! TurtleDoc(String(contentsOf: turtleFile))
//        NSLog("%@", "turtleDoc = \(String(describing: turtleDoc))")
let subjects = turtleDoc.triples.compactMap {SubjectDescription($0)}

struct CamelIdentifier {
    var id: String
    var firstLoweredID: String {return (id.first?.lowercased() ?? "") + id.dropFirst()}
    init(raw: String) {
        id = raw.components(separatedBy: .init(charactersIn: ":-"))
            .map {($0.first?.uppercased() ?? "") + $0.dropFirst()}
            .joined()
    }
}

struct IRIBaseProvider {
    let name: PNameNS
    let iri: IRIRef
    var typeName: String {return CamelIdentifier(raw: name.value!).id + "Schema"}

    var swiftCode: String {
        return """
        public enum \(typeName): IRIBaseProvider {
            public static var base: IRIRef {return IRIRef(value: "\(iri.value)")}
        }
        """
    }
}

extension IRIRef {
    init?(_ prefixedName: PrefixedName, on prologues: [Prologue]) {
        let ns: PNameNS
        let local: String?
        switch prefixedName {
        case .ln(let n, let l): (ns, local) = (n, l)
        case .ns(let n): (ns, local) = (n, nil)
        }

        guard let iri: IRIRef = (prologues.lazy.compactMap {
            switch $0 {
            case .prefix(ns, let iri): return iri
            case .prefix: return nil
            case .base(let iri): return ns.value == nil ? iri : nil
            }
            }.first) else { return nil }
        self.init(value: iri.value + (local ?? ""))
    }
    init?(_ iri: IRI, on prologues: [Prologue]) {
        switch iri {
        case .ref(let iri): self.init(value: iri.value)
        case .prefixedName(let p): self.init(p, on: prologues)
        }
    }
}

struct RDFTypeConvertible {
    let type: CamelIdentifier
    let schema: IRIBaseProvider
    let local: String

    init?(_ subject: TurtleDoc.Subject, directives: [IRIBaseProvider], prologues: [Prologue]) {
        switch subject {
        case .iri(let iri):
            guard let d = (directives.first {IRIRef(iri, on: prologues)!.value.hasPrefix($0.iri.value)}) else { return nil }
            schema = d
            switch iri {
            case .prefixedName(.ln(_, let local)):
                self.type = CamelIdentifier(raw: Serializer.serialize(iri))
                self.local = local
            case .prefixedName(.ns): return nil
            case .ref: return nil
            }
        default: return nil
        }
    }

    var swiftCode: String {
        return """
        public struct \(type.id): RDFTypeConvertible {
            public typealias Schema = \(schema.typeName)
            public static var rdfType: IRIRef {return Schema.rdfType("\(local)")}
        }

        extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
            public func rdfTypeIs\(type.id)() -> TripleBuilder<TripleBuilderStateRDFTypeBound<\(type.id)>> {return rdfType(is: \(type.id).self)}
        }
        """
    }
}

struct TripleBuilderStateRDFTypeBoundType {
    let type: CamelIdentifier
    let verbs: [(prefix: String, schema: String, local: String, label: String?, comment: String?)]

    init?(subject: TurtleDoc.Subject, verbs: [String], directives: [IRIBaseProvider], properties: [SubjectDescription], prologues: [Prologue]) {
        switch subject {
        case .iri(let v): type = CamelIdentifier(raw: Serializer.serialize(v))
        default: return nil
        }
        self.verbs = verbs.map { v in
            let d = directives.first {v.hasPrefix($0.iri.value)}
            let p = properties.first {
                switch $0.subject {
                case .iri(let iri): return IRIRef(iri, on: prologues) == IRIRef(value: v)
                case .blank, .collection: return false
                }
            }
            return (d?.name.value ?? "",
                    d?.typeName ?? "",
                    d.map {v.replacingOccurrences(of: $0.iri.value, with: "")} ?? v,
                    p?.label,
                    p?.comment)
        }
    }

    var swiftCode: String {
        let verbFuncs = verbs.map { v -> String in
            let docComment = [v.label, v.comment].compactMap {$0}.joined(separator: ": ")
                .components(separatedBy: .newlines)
                .map {"/// " + $0}
                .joined(separator: "\n")
            let funcName = CamelIdentifier(raw: v.prefix + CamelIdentifier(raw: v.local).id).firstLoweredID
            return """
\(docComment)
func \(funcName)(is v: RDFLiteral) -> TripleBuilder<State> {
    return appended(verb: \(v.schema).verb("\(v.local)"), value: [.literal(v)])
}

\(docComment)
func \(funcName)(is v: Var) -> TripleBuilder<State> {
    return appended(verb: \(v.schema).verb("\(v.local)"), value: [.var(v)])
}
"""
        }

        return """
        public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == \(type.id) {
        \(verbFuncs.joined(separator: "\n\n")
        .components(separatedBy: .newlines)
        .map {"    " + $0}
        .joined(separator: "\n"))
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

let properties = subjects.filter {
    switch $0.a {
    case .prefixedName(.ln((PNameNS(value: "rdf"), "Property")))?: return true
    default: return false
    }
}

struct VerbResponse: Codable {
    var v: String
}

let prologues = directives.map {Prologue.prefix($0.name, $0.iri)}

SignalProducer(classes)
    .flatMap(.concat) { subjectDescription in
        SignalProducer<Data, NoError> { observer, lifetime in
            let iriRef: IRIRef
            switch subjectDescription.subject {
            case .iri(let iri):
                guard let ref = IRIRef(iri, on: prologues) else { fatalError() }
                iriRef = ref
            case .blank, .collection: fatalError()
            }

            let query = Query(
                select: SelectQuery(
                    option: .distinct,
                    capture: .vars([Var("v")]),
                    where: WhereClause(patterns: [
                        .triple(.var(Var("s")), RDFSyntaxNSSchema.verb("type"), [.varOrTerm(.term(.iri(.ref(iriRef))))]),
                        .triple(.var(Var("s")), .simple(Var("v")), [.var(Var("o"))])
                        ])))
            URLSession.shared.dataTask(with: Request(endpoint: endpoint, query: query).request) { (data, response, error) in
                guard let data = data else {fatalError()}
                observer.send(value: data)
                observer.sendCompleted()
                }.resume()
            }
            .map {(subjectDescription, try! SRJBindingsDecoder().decode(VerbResponse.self, from: $0))}
            .delay(0.2, on: QueueScheduler.main)
    }
    .on(value: { sd, vs in
        let type: String
        switch sd.subject {
        case .iri(let v): type = Serializer.serialize(v)
        case .blank(let v): type = Serializer.serialize(v)
        case .collection(let v): type = String(describing: v)
        }
        print("\(type) has \(vs.count) verbs")})
    .collect()
    .startWithValues { values in
        let rdfTypeConvertibles = values.compactMap { subjectDescription, _ in
            RDFTypeConvertible(subjectDescription.subject, directives: directives, prologues: prologues)
        }
        let verbExtensions = values.compactMap { subjectDescription, verbs in
            TripleBuilderStateRDFTypeBoundType(
                subject: subjectDescription.subject,
                verbs: verbs.map {$0.v},
                directives: directives,
                properties: properties,
                prologues: prologues)
        }
        let swiftCodes = directives.map {$0.swiftCode}
            + rdfTypeConvertibles.map {$0.swiftCode}
            + verbExtensions.map {$0.swiftCode}
        // print(swiftCodes.joined(separator: "\n\n"))
        print(swiftCodes.joined(separator: "\n\n"))
}

dispatchMain()
