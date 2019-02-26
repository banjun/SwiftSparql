import SwiftSparql

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
}

