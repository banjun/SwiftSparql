import Foundation

public struct Request {
    public let endpoint: URL
    public let query: Query

    public init(endpoint: URL, query: Query) {
        self.endpoint = endpoint
        self.query = query
    }

    public var request: URLRequest {
        let u = URL(string: "?query=" + Serializer.serialize(query).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                    relativeTo: endpoint)!
        return URLRequest(url: u)
    }
}
