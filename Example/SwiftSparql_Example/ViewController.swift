import Cocoa
import SwiftSparql

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // playground

        let prologues: [Prologue] = [
            .prefix(PNameNS(value: "schema"), IRIRef(value: "http://schema.org/")),
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
        print("\n\n\n")

        let heightQuery = Query(prologues: prologues, select: SelectQuery(
            capture: .vars(["?o", "?h"]),
            where: WhereClause(
                first: TriplesBlock(
                    triplesSameSubjectPath: TriplesSameSubjectPath.varOrTerm(
                        .var("?s"),
                        .init(verb: .path((PNameNS(value: "schema"), "name") | (PNameNS(value: "schema"), "alternateName")),
                              objectListPath: [.varOrTerm(.var("?o"))],
                              successors: [(.init((PNameNS(value: "schema"), "height")),  [.varOrTerm(.var("?h"))])])),
                    triplesBlock: nil),
                successors: []),
            order: [.asc(.init("?h")), .var("?s")],
            limit: .limit(10)))
        NSLog("%@", "heightQuery = \n\n\(Serializer.serialize(heightQuery))")
        print("\n\n\n")

        let unitMembers = Query(prologues: prologues, select: SelectQuery(
            capture: .expressions([
                ("?ユニット名", nil),
                ("?メンバー", Expression(BuiltInCall.groupConcat(distinct: false, expression: Expression("?名前"), separator: ", ")))]),
            where: WhereClause(
                first: TriplesBlock(
                    triplesSameSubjectPath: TriplesSameSubjectPath.varOrTerm(
                        .var("?s"),
                        .init(verb: .init((PNameNS(value: "rdf"), "type")),
                              objectListPath: [.varOrTerm(.term(.iri(.prefixedName(.ln((PNameNS(value: "imas"), "Unit"))))))],
                              successors: [(.init((PNameNS(value: "schema"), "name")),  [.varOrTerm(.var("?ユニット名"))]),
                                           (.init((PNameNS(value: "schema"), "member")),  [.varOrTerm(.var("?m"))])])),
                    triplesBlock: TriplesBlock(
                        triplesSameSubjectPath: .varOrTerm(
                            .var("?m"), .init(verb: .init((PNameNS(value: "schema"), "name")), objectListPath: [.varOrTerm(.var("?名前"))], successors: [])),
                        triplesBlock: nil)),
                successors: []),
            group: [.var("?ユニット名")],
            order: [.var("?ユニット名")],
            limit: .limit(10)))
        NSLog("%@", "unitMembers = \n\n\(Serializer.serialize(unitMembers))")
    }
}
