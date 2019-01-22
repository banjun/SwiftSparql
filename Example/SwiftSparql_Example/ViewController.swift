import Cocoa
import SwiftSparql
import BrightFutures

enum QueryError: Error {
    case urlSession(Error?)
    case decode(Error)
}

private func fetch<T: Codable>(_ query: Query) -> Future<[T], QueryError> {
    let endpoint = URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!
    return Future<[T], QueryError> { resolve in
        URLSession.shared.dataTask(with: Request(endpoint: endpoint, query: query).request) { data, response, error in
            guard let data = data else {
                return resolve(.failure(.urlSession(error)))
            }

            do {
                let r = try SRJBindingsDecoder().decode(T.self, from: data)
                resolve(.success(r))
            } catch {
                return resolve(.failure(.decode(error)))
            }
            }.resume()
    }
}

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

        let varS = VarOrTerm.var("?s")
        let varName = VarOrTerm.var("?name")
        let varHeight = Var("?身長")
        let rdfType = PropertyListPathNotEmpty.Verb((PNameNS(value: "rdf"), "type"))
        let schemaName = PropertyListPathNotEmpty.Verb((PNameNS(value: "schema"), "name"))
        let schemaHeight = PropertyListPathNotEmpty.Verb((PNameNS(value: "schema"), "height"))
        let imasIdol = ObjectPath.varOrTerm(.term(.iri(.prefixedName(.ln((PNameNS(value: "imas"), "Idol"))))))
        let idolNames = Query(prologues: prologues, select: SelectQuery(
            where: WhereClause(patterns: [
                .triple(varS, rdfType, [imasIdol]),
                .triple(varS, schemaName, [.varOrTerm(varName)]),
                .triple(varS, schemaHeight, [.varOrTerm(.var(varHeight))]),
                ]),
            having: [.logical(NumericExpression(varHeight) <= 149)],
            order: [.constraint(.builtInCall(.RAND))],
            limit: .limit(10)))
        NSLog("%@", "idolNames = \n\n\(Serializer.serialize(idolNames))")
        print("\n\n\n")

        fetch(liveSongs).onSuccess { (songs: [LiveSong]) in
            NSLog("%@", "query response: songs = \(songs)")
            }
            .onFailure {NSLog("%@", String(describing: $0))}

        fetch(idolNames)
            .onSuccess { (idols: [IdolHeight]) in
                NSLog("%@", "query response: idols = \(idols)")
            }
            .onFailure {NSLog("%@", String(describing: $0))}
    }
}

struct LiveSong: Codable {
    var 楽曲名: String
    var 回数: Int
}

struct IdolHeight: Codable {
    var name: String
    var 身長: Double
}
