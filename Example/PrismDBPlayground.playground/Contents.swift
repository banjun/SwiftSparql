import Cocoa
import SwiftSparql
import BrightFutures
import PlaygroundSupport


@_functionBuilder
struct VerbObjectBuilder {
    static func buildBlock<T>(_ builders: TripleBuilder<TripleBuilderStateRDFTypeBound<T>>...) -> [GroupGraphPatternSubType] {
        builders.flatMap {$0.triples}
    }
}

struct Subject<Class: RDFTypeConvertible>: TriplesBuildable {
    var v: Var
    var triples: [GroupGraphPatternSubType]
}
// should be generated
extension Subject where Class == PrismLive {
    init(_ varname: String, @VerbObjectBuilder builder: (TripleBuilder<TripleBuilderStateRDFTypeBound<Class>>) -> [GroupGraphPatternSubType] = {_ in []}) {
        self.v = Var(varname)
        self.triples = builder(subject(v).rdfTypeIsPrismLive())
    }
}
// should be generated
extension Subject where Class == PrismSong {
    init(_ varname: String, @VerbObjectBuilder builder: (TripleBuilder<TripleBuilderStateRDFTypeBound<Class>>) -> [GroupGraphPatternSubType] = {_ in []}) {
        self.v = Var(varname)
        self.triples = builder(subject(v).rdfTypeIsPrismSong())
    }
}
// should be generated
extension Subject where Class == PrismEpisode {
    init(_ varname: String, @VerbObjectBuilder builder: (TripleBuilder<TripleBuilderStateRDFTypeBound<Class>>) -> [GroupGraphPatternSubType] = {_ in []}) {
        self.v = Var(varname)
        self.triples = builder(subject(v).rdfTypeIsPrismEpisode())
    }
}

protocol TriplesBuildable {
    var triples: [GroupGraphPatternSubType] { get }
}

@_functionBuilder
struct WhereBuilder {
    static func buildBlock(_ builder: TriplesBuildable) -> [GroupGraphPatternSubType] {
        builder.triples
    }
    static func buildBlock(_ builders: TriplesBuildable...) -> [GroupGraphPatternSubType] {
        builders.flatMap {$0.triples}
    }
}

struct Where {
    var triples: [GroupGraphPatternSubType]

    init(@WhereBuilder builder: () -> [GroupGraphPatternSubType]) {
        self.triples = builder()
    }
}
extension Where {
    var query: SelectQuery {
        SelectQuery(where: WhereClause(patterns: triples))
    }
}

let q = Where {
    Subject<PrismLive>("live") {
        $0.prismPerformer(is: "solami_smile")
        $0.prismSongPerformed(is: Var("song"))
        $0.prismLiveOfEpisode(is: Var("ep"))
    }
    Subject<PrismSong>("song") {
        $0.prismName(is: Var("title"))
        $0.prismName(is: Var("title")) // builder args should be list
    }
    Subject<PrismEpisode>("ep") {
        $0.prism話数(is: Var("n"))
        $0.prismサブタイトル(is: Var("st"))
    }
}.query
print(Serializer.serialize(q))

struct EpisodeSong: Codable {
    var n: String
    var st: String
    var title: String
}

let query = SelectQuery(
    capture: .vars([Var("n"), Var("st"), Var("title")]),
    where: WhereClause(patterns:
        subject(Var("live")).rdfTypeIsPrismLive()
            .prismPerformer(is: "solami_smile")
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
