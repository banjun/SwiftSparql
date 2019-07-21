import SwiftSparql

struct TripleBuilderStateRDFTypeBoundType {
    let type: CamelIdentifier
    let verbs: [(prefix: String, schema: String, local: String, label: String?, comment: String?)]

    init?(subject: TurtleDoc.Subject, verbs: [String], directives: [IRIBaseProvider], properties: [SubjectDescription], prologues: [Prologue]) {
        switch subject {
        case .iri(let iri):
            switch iri {
            case .prefixedName: type = CamelIdentifier(raw: Serializer.serialize(iri))
            case .ref(let ref):
                guard let d = (directives.first {ref.value.hasPrefix($0.iri.value)}) else { return nil }
                let local = ref.value.replacingOccurrences(of: d.iri.value, with: "")
                let iri = IRI.prefixedName(.ln((d.name, local)))
                type = CamelIdentifier(raw: Serializer.serialize(iri))
            }
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
}
