import Foundation
import SwiftSparql
import ReactiveSwift
import enum Result.NoError

struct TurtleFetcher {
    var urls: [URL]

    init(urls: [URL]) {
        self.urls = urls
    }

    func fetch(completion: @escaping ([TurtleDoc]) -> Void) {
        SignalProducer(urls)
            .on(value: {print("fetching \($0)")})
            .flatMap(.concat) { url in
                SignalProducer<Data, NoError> { observer, lifetime in
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        guard let data = data else { fatalError(String(describing: error)) }
                        observer.send(value: data)
                        observer.sendCompleted()
                        }
                        .resume()
                }
            }
            .on(value: {print("parsing \($0.count) bytes")})
            .map {
                do {
                    return try TurtleDoc(String(data: $0, encoding: .utf8)!)
                } catch {
                    fatalError(String(describing: error))
                }
            }
            .collect()
            .startWithValues(completion)
    }
}
