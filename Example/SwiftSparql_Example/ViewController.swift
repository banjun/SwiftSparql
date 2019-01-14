import Cocoa
import SwiftSparql

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // playground

        let prologues: [Prologue] = [
            .prefix(PNameNS(value: "rdf"), IRIRef(value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#")),
            .prefix(PNameNS(value: "imas"), IRIRef(value: "https://sparql.crssnky.xyz/imasrdf/URIs/imas-schema.ttl#")),
            ]

        let query = Query(prologues: prologues, select: SelectQuery(
            where: WhereClause(pattern: GroupGraphPattern.groupGraphPatternSub(GroupGraphPatternSub(
                first: TriplesBlock(triplesSameSubjectPath: TriplesSameSubjectPath.varOrTerm(
                    .var("?s"),
                    PropertyListPathNotEmpty(verb: PropertyListPathNotEmpty.Verb.path([
                        [PathEltOrInverse.elt(PathElt(primary: PathPrimary.iri(IRI.prefixedName(PrefixedName.ln((PNameNS(value: "rdf"), "type")))), mod: nil))]]),
                                             objectListPath: [.varOrTerm(.var("?o"))],
                                             successors: [])),
                                    triplesBlock: nil),
                successors: []))),
            limit: .limit(10)))
        
        NSLog("%@", "selectQuery = \n\n\(Serializer.serialize(query))")
    }
}
