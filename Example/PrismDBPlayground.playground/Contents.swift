import Cocoa
import SwiftSparql
import BrightFutures
import PlaygroundSupport

protocol TriplesBuildable {
    var triples: [GroupGraphPatternSubType] { get }
}
extension TripleBuilder: TriplesBuildable {}
struct TriplesList: TriplesBuildable {
    var builders: [TriplesBuildable]
    var triples: [GroupGraphPatternSubType] {builders.flatMap {$0.triples}}
}

@_functionBuilder
struct WhereClauseBuilder {
    static func buildBlock(_ builders: TriplesBuildable...) -> TriplesBuildable {
        TriplesList(builders: builders)
    }
}

extension WhereClause {
    init(@WhereClauseBuilder builder: () -> TriplesBuildable) {
        self.init(patterns: builder().triples)
    }
}

struct EpisodeSong: Codable {
    var n: String
    var st: String
    var title: String
}

let query = SelectQuery(
    capture: .vars([Var("n"), Var("st"), Var("title")]),
    where: WhereClause {
        subject(Var("live")).rdfTypeIsPrismLive()
            .prismPerformer(is: "solami_smile")
            .prismSongPerformed(is: Var("song"))
            .prismLiveOfEpisode(is: Var("ep"))
        subject(Var("song")).rdfTypeIsPrismSong()
            .prismName(is: Var("title"))
        subject(Var("ep")).rdfTypeIsPrismEpisode()
            .prism話数(is: Var("n"))
            .prismサブタイトル(is: Var("st"))
    },
    order: [.by(Var("n"))],
    limit: 100)

print(Serializer.serialize(query))

Request(endpoint: URL(string: "https://prismdb.takanakahiko.me/sparql/")!, select: query)
    .fetch()
    .onSuccess { (results: [EpisodeSong]) in
        results
        print("\nSoLaMi♡SMILE has...\n")
        results.forEach {
            print("performed \($0.title) in ep \($0.n) 「\($0.st)」 ")
        }
    }.onFailure {print($0)}

PlaygroundPage.current.needsIndefiniteExecution = true
