import Foundation
import BrightFutures

public enum QueryError: Error {
    case urlSession(Error?)
    case decode(Error)
}

public extension Request {
    func fetch<T: Decodable>() -> Future<[T], QueryError> {
        return .init { resolve in
            URLSession.shared.dataTask(with: self.request) { data, response, error in
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
}
