import Cocoa
import SwiftSparql
import BrightFutures

func fetch<T: Decodable>(_ select: SelectQuery) -> Future<[T], QueryError> {
    return Request(endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!, select: select).fetch()
}

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // playground

        let query = Query(select: SelectQuery(
            where: WhereClause(patterns: [
                .triple(.var(Var("s")), PropertyListPathNotEmpty.Verb.init((PNameNS(value: "rdf"), "type")), [.var(Var("o"))]),
                ]),
            limit: 10))

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
            order: [.asc(v: Var("h")), .by(Var("s"))],
            limit: 10))
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
            order: [.by(Var("ユニット名"))],
            limit: 10))
        NSLog("%@", "unitMembers = \n\n\(Serializer.serialize(unitMembers))")
        print("\n\n\n")

        let mayukiki = Query(select: SelectQuery(
            capture: .vars([Var("利き手"), Var("名前")]),
            where: WhereClause(patterns:
                subject(Var("s"))
                    .rdfTypeIsImasIdol()
                    .alternative({[$0.schemaName, $0.schemaAlternateName]}, is: Var("name"))
                    .imasHandedness(is: Var("利き手"))
                    .filter(.CONTAINS(v: Var("name"), sub: "まゆ"))
                    .triples
                    + subject(Var("idol"))
                        .rdfTypeIsImasIdol()
                        .imasHandedness(is: Var("利き手"))
                        .schemaName(is: Var("名前"))
                        .triples),
            limit: 10))
        NSLog("%@", "mayukiki = \n\n\(Serializer.serialize(mayukiki))")
        print("\n\n\n")

        let liveSongs = SelectQuery(
            capture: .expressions([(Var("回数"), .init(.count(distinct: false, expression: .init(Var("name"))))),
                                   (Var("楽曲名"), .init(.sample(distinct: false, expression: .init(Var("name")))))]),
            where: WhereClause(patterns:
                subject(Var("s"))
                    .rdfTypeIsImasSetlistNumber()
                    .schemaName(is: Var("name"))
                    .triples),
            group: [.var(Var("name"))],
            having: [.logical(Var("回数") > 4)],
            order: [.desc(v: Var("回数"))],
            limit: 10)
        NSLog("%@", "liveSongs = \n\n\(Serializer.serialize(liveSongs))")
        print("\n\n\n")

        let varS = Var("s")
        let varName = Var("name")
        let varHeight = Var("身長")
        let idolNames = SelectQuery(
            where: WhereClause(patterns:
                subject(varS).rdfTypeIsImasIdol()
                    .imasNameKana(is: varName)
                    .schemaHeight(is: varHeight)
                    .optional {$0.imasColor(is: Var("color"))}
                    .triples),
            having: [.logical(varHeight <= 149)],
            order: [.by(.RAND)],
            limit: 10)
        NSLog("%@", "idolNames = \n\n\(Serializer.serialize(idolNames))")
        print("\n\n\n")

        let today: String = {
            let df = DateFormatter()
            df.dateFormat = "MM-dd"
            return df.string(from: Date())
        }()
        let birthdays = SelectQuery(
            capture: .expressions([
                // NOTE: `sample` aggregation returns `{}` empty hash in bindings on empty result and that cause Decoding error
                (varName, Expression(.sample(distinct: false, expression: .init(Var("なまえ"))))),
                (Var("date"), Expression(.sample(distinct: false, expression: .init(Var("誕生日"))))),
                ]),
            where: WhereClause(patterns:
                subject(varS)
                    .rdfTypeIsImasIdol()
                    .schemaBirthDate(is: Var("誕生日"))
                    .alternative({[$0.schemaName, $0.schemaAlternateName]}, is: Var("なまえ"))
                    .filter(.regex(v: Var("誕生日"), pattern: today))
                    .triples),
            group: [.var(Var("なまえ"))],
            order: [.by(varName)]
            )
        NSLog("%@", "birthdays = \n\n\(Serializer.serialize(birthdays))")
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

        fetch(birthdays).onSuccess{ (idols: [Idol]) in
            NSLog("%@", "query response: birthdays = \(idols)")
            }
            .onFailure {NSLog("birthdays: %@", String(describing: $0))}

        let units = SelectQuery(
            capture: .expressions([
                (Var("name"), Expression(Var("ユニット名"))),
                (Var("memberNames_concat"), Expression(.groupConcat(distinct: false, expression: Expression(Var("ユニットメンバー名")), separator: ","))),
                (Var("types_concat"), Expression(.groupConcat(distinct: false, expression: Expression(Var("ユニットメンバー属性")), separator: ",")))]),
            where: WhereClause(patterns:
                subject(Var("橘ありす"))
                    .rdfTypeIsImasIdol()
                    .schemaName(is: .literal("橘ありす", lang: "ja"))
                    .schemaMemberOf(is: Var("ありす参加ユニット"))
                    .triples
                    + subject(Var("ありす参加ユニット"))
                        .rdfTypeIsImasUnit()
                        .schemaName(is: Var("ユニット名"))
                        .schemaMember(is: Var("ユニットメンバー"))
                        .triples
                    + subject(Var("ユニットメンバー"))
                        .rdfTypeIsImasIdol()
                        .schemaName(is: Var("ユニットメンバー名"))
                        .imasType(is: Var("ユニットメンバー属性"))
                        .triples),
            group: [.var(Var("ユニット名"))],
            order: [.by(.count(distinct: false, expression: Expression(Var("ユニットメンバー"))))],
            limit: 100)
        print("units = \n\n\(Serializer.serialize(units))")
        print("\n\n\n")
        fetch(units).onSuccess { (units: [Unit]) in
            print("query response: units = \n\(units.map {$0.description}.joined(separator: "\n"))")
            }
            .onFailure {NSLog("units: %@", String(describing: $0))}
    }
}

struct LiveSong: Codable {
    var 楽曲名: String
    var 回数: Int
}

struct Idol: Codable {
    var name: String
}

struct IdolHeight: Codable {
    var name: String
    var 身長: Double
}

struct Unit: Codable, CustomStringConvertible {
    var name: String
    private var memberNames_concat: String
    private var types_concat: String

    var members: [(name: String, type: String)] {
        return Array(zip(memberNames_concat.components(separatedBy: ","),
                         types_concat.components(separatedBy: ",")))
    }
    var description: String {
        return members.map {$0.name + "(\($0.type))"}.joined(separator: " と ") + " で " + name
    }
}
