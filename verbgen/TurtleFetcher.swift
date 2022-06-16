import Foundation
import SwiftSparql
import ReactiveSwift

struct TurtleFetcher {
    var urls: [URL]

    init(urls: [URL]) {
        self.urls = urls
    }

    @available(macOS 10.15, *)
    func fetch() async -> [TurtleDoc] {
        await withUnsafeContinuation { fetch(completion: $0.resume) }
    }
    func fetch(completion: @escaping ([TurtleDoc]) -> Void) {
        SignalProducer(urls)
            .on(value: {print("fetching \($0)")})
            .flatMap(.concat) { url in
                SignalProducer<Data, Never> { observer, lifetime in
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        guard let data = data else { fatalError(String(describing: error)) }
                        print("fetched \(url)")
                        observer.send(value: data)
                        observer.sendCompleted()
                        }
                        .resume()
                }.map {(url, $0)}
            }
            .on(value: {print("parsing \($1.count) bytes from: \($0)")})
            .map { url, data in
                do {
                    return try TurtleDoc(String(data: data, encoding: .utf8)!)
                } catch {
                    fatalError("error while parsing \(url): \(String(describing: error))")
                }
            }
            .collect()
            .startWithValues(completion)
    }
}
