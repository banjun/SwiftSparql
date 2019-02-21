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

        let turtleDoc = try! TurtleDoc(String(contentsOfFile: Bundle.main.path(forResource: "imas-schema", ofType: "ttl")!))
//        NSLog("%@", "turtleDoc = \(String(describing: turtleDoc))")

//        let swiftCodes = turtleDoc.triples.compactMap {SubjectDescription($0)}.map {$0.swiftCode}
//        print(swiftCodes.joined(separator: "\n\n"))
//
//        exit(1)

        let query = Query(select: SelectQuery(
            where: WhereClause(patterns: [
                .triple(.var(Var("s")), PropertyListPathNotEmpty.Verb.init((PNameNS(value: "rdf"), "type")), [.var(Var("o"))]),
                ]),
            limit: .limit(10)))

        NSLog("%@", "selectQuery = \n\n\(Serializer.serialize(query))")
        print("\n\n\n")


        let heightQuery = Query(select: SelectQuery(
            capture: .vars([Var("o"), Var("h")]),
            where: WhereClause(patterns:
                subject(Var("s"))
                    .rdfTypeIsImasIdol()
                    .alternative({[$0.schemaName, $0.schemaAlternateName]}, is: Var("o"))
                    .schemaHeight(is: Var("h"))
                    .triples),
            order: [.asc(.init(Var("h"))), .var(Var("s"))],
            limit: .limit(10)))
        NSLog("%@", "heightQuery = \n\n\(Serializer.serialize(heightQuery))")
        print("\n\n\n")

        let unitMembers = Query(select: SelectQuery(
            capture: SelectClause.Capture.expressions([
                (Var("ユニット名"), nil),
                (Var("メンバー"), Expression(.groupConcat(distinct: false, expression: Expression(Var("名前")), separator: ", ")))]),
            where: WhereClause(patterns:
                subject(Var("s"))
                    .rdfTypeIsImasUnit()
                    .schemaName(is: Var("ユニット名"))
                    .schemaMember(is: Var("m"))
                    .triples
                    + subject(Var("m"))
                        .rdfTypeIsImasIdol()
                        .schemaName(is: Var("名前"))
                        .triples),
            group: [.var(Var("ユニット名"))],
            order: [.var(Var("ユニット名"))],
            limit: .limit(10)))
        NSLog("%@", "unitMembers = \n\n\(Serializer.serialize(unitMembers))")
        print("\n\n\n")

        let mayukiki = Query(select: SelectQuery(
            capture: .vars([Var("利き手"), Var("名前")]),
            where: WhereClause(patterns:
                subject(Var("s"))
                    .rdfTypeIsImasIdol()
                    .alternative({[$0.schemaName, $0.schemaAlternateName]}, is: Var("name"))
                    .handedness(is: Var("利き手"))
                    .triples
                    + [GroupGraphPatternSubType.filter(.regex(.init(.STR(.init(Var("name")))), "まゆ", nil))]
                    + subject(Var("idol"))
                        .rdfTypeIsImasIdol()
                        .handedness(is: Var("利き手"))
                        .schemaName(is: Var("名前"))
                        .triples),
            limit: .limit(10)))
        NSLog("%@", "mayukiki = \n\n\(Serializer.serialize(mayukiki))")
        print("\n\n\n")

        let liveSongs = Query(select: SelectQuery(
            capture: .expressions([(Var("回数"), .init(.count(distinct: false, expression: .init(Var("name"))))),
                                   (Var("楽曲名"), .init(.sample(distinct: false, expression: .init(Var("name")))))]),
            where: WhereClause(patterns:
                subject(Var("s"))
                    .rdfType(is: ImasSetlistNumber.self)
                    .name(is: Var("name"))
                    .triples),
            group: [.var(Var("name"))],
            having: [.logical(NumericExpression(Var("回数")) > 4)],
            order: [.desc(.init(Var("回数")))],
            limit: .limit(10)))
        NSLog("%@", "liveSongs = \n\n\(Serializer.serialize(liveSongs))")
        print("\n\n\n")

        let varS = Var("s")
        let varName = Var("name")
        let varHeight = Var("身長")
        let idolNames = Query(select: SelectQuery(
            where: WhereClause(patterns:
                subject(varS).rdfTypeIsImasIdol()
                    .nameKana(is: varName)
                    .schemaHeight(is: varHeight)
                    .optional {$0.color(is: Var("color"))}
                    .triples),
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

enum ImasSetlistNumber: RDFTypeConvertible {
    typealias Schema = ImasSchema
    static var rdfType: IRIRef {return Schema.rdfType("SetlistNumber")}
}

extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == ImasSetlistNumber {
    func name(is v: Var) -> TripleBuilder<State> {
        return .init(base: self, appendingVerb: SchemaOrg.verb("name"), value: [.var(v)])
    }
}
