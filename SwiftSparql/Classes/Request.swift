import Foundation

public struct Request {
    public let endpoint: URL
    public let query: Query

    public init(endpoint: URL, query: Query) {
        self.endpoint = endpoint
        self.query = query
    }

    public init(endpoint: URL, select: SelectQuery) {
        self.init(endpoint: endpoint, query: Query(select: select))
    }

    public var request: URLRequest {
        let u = URL(string: "?query=" + Serializer.serialize(query).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            + "&format=application%2Fsparql-results%2Bjson",
                    relativeTo: endpoint)!
        return URLRequest(url: u)
    }
}
