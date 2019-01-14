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
        print("\n\n\n")

        let mayukiki = Query(prologues: prologues, select: SelectQuery(
            capture: .vars(["?利き手", "?名前"]),
            where: WhereClause(
                first: TriplesBlock(
                    triplesSameSubjectPath: .varOrTerm(
                        .var("?s"),
                        .init(verb: .path((PNameNS(value: "schema"), "name") | (PNameNS(value: "schema"), "alternateName")), objectListPath: [.varOrTerm(.var("?name"))],
                              successors: [(.init((PNameNS(value: "imas"), "Handedness")), [.varOrTerm(.var("?利き手"))])])),
                    triplesBlock: nil),
                successors: [(.Filter(.builtInCall(.regex(.init(.STR(.init("?name"))), "まゆ", nil))), TriplesBlock(
                    triplesSameSubjectPath: TriplesSameSubjectPath.varOrTerm(
                        .var("?idol"),
                        .init(verb: .init((PNameNS(value: "imas"), "Handedness")), objectListPath: [.varOrTerm(.var("?利き手"))],
                              successors: [(.init((PNameNS(value: "schema"), "name")), [.varOrTerm(.var("?名前"))])])),
                    triplesBlock: nil))]),
            limit: .limit(10)))
        NSLog("%@", "mayukiki = \n\n\(Serializer.serialize(mayukiki))")
        print("\n\n\n")

        let mayukiki2 = Query(prologues: prologues, select: SelectQuery(
            capture: .vars(["?利き手", "?名前"]),
            where: WhereClause(patterns: [
                .triple(.var("?s"), .path((PNameNS(value: "schema"), "name") | (PNameNS(value: "schema"), "alternateName")), [.varOrTerm(.var("?name"))]),
                .triple(.var("?s"), .init((PNameNS(value: "imas"), "Handedness")), [.varOrTerm(.var("?利き手"))]),
                .notTriple(.Filter(.builtInCall(.regex(.init(.STR(.init("?name"))), "まゆ", nil)))),
                .triple(.var("?idol"), .init((PNameNS(value: "imas"), "Handedness")), [.varOrTerm(.var("?利き手"))]),
                .triple(.var("?idol"), .init((PNameNS(value: "schema"), "name")), [.varOrTerm(.var("?名前"))]),
                ]),
            limit: .limit(10)))
        NSLog("%@", "mayukiki2 = \n\n\(Serializer.serialize(mayukiki2))")
        print("\n\n\n")

        let liveSongs = Query(prologues: prologues, select: SelectQuery(
            capture: .expressions([("?回数", .init(.count(distinct: false, expression: .init("?name")))),
                                   ("?楽曲名", .init(.sample(distinct: false, expression: .init("?name"))))]),
            where: WhereClause(
                first: TriplesBlock(
                    triplesSameSubjectPath: .varOrTerm(
                        .var("?s"),
                        .init(verb: .init((PNameNS(value: "rdf"), "type")), objectListPath: [.varOrTerm(.term(.iri(.prefixedName(.ln((PNameNS(value: "imas"), "SetlistNumer"))))))],
                              successors: [(.init((PNameNS(value: "schema"), "name")), [.varOrTerm(.var("?name"))])])),
                    triplesBlock: nil),
                successors: []),
            group: [.var("?name")],
            having: [.logical(NumericExpression("?回数") > 4)],
            order: [.desc(.init("?回数"))],
            limit: .limit(10)))
        NSLog("%@", "liveSongs = \n\n\(Serializer.serialize(liveSongs))")
        print("\n\n\n")
    }
}
