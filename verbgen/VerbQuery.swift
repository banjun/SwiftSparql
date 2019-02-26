import SwiftSparql
import Foundation

struct VerbQuery {
    var endpoint: URL
    var query: Query

    struct Response: Codable {
        var v: String
    }

    init(_ subjectDescription: SubjectDescription, endpoint: URL, prologues: [Prologue]) {
        self.endpoint = endpoint

        let iriRef: IRIRef
        switch subjectDescription.subject {
        case .iri(let iri):
            guard let ref = IRIRef(iri, on: prologues) else { fatalError() }
            iriRef = ref
        case .blank, .collection: fatalError()
        }

        query = Query(
            select: SelectQuery(
                option: .distinct,
                capture: .vars([Var("v")]),
                where: WhereClause(patterns: [
                    .triple(.var(Var("s")), _RdfSchema.verb("type"), [.varOrTerm(.term(.iri(.ref(iriRef))))]),
                    .triple(.var(Var("s")), .simple(Var("v")), [.var(Var("o"))])
                    ])))
    }
    
    func fetch(completion: @escaping ([Response]) -> Void) {
        URLSession.shared.dataTask(with: Request(endpoint: endpoint, query: query).request) { (data, response, error) in
            guard let data = data else {fatalError()}
            completion(try! SRJBindingsDecoder().decode(Response.self, from: data))
            }.resume()
    }
}
