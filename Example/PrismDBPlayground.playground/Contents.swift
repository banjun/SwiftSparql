import Cocoa
import SwiftSparql
import BrightFutures
import PlaygroundSupport

struct EpisodeSong: Codable {
    var n: String
    var st: String
    var title: String
}

let query = SelectQuery(
    capture: .vars([Var("n"), Var("st"), Var("title")]),
    where: WhereClause(patterns:
        subject(Var("team")).rdfTypeIsPrismTeam()
            .prismName_kana(is: "そらみすまいる")
            .triples
            + subject(Var("live")).rdfTypeIsPrismLive()
                .prismPerformer(is: Var("team"))
                .prismSongPerformed(is: Var("song"))
                .prismLiveOfEpisode(is: Var("ep"))
                .triples
            + subject(Var("song")).rdfTypeIsPrismSong()
                .prismName(is: Var("title"))
                .triples
            + subject(Var("ep")).rdfTypeIsPrismEpisode()
                .prism話数(is: Var("n"))
                .prismサブタイトル(is: Var("st"))
                .triples
    ),
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
