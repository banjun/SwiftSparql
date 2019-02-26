struct CamelIdentifier {
    var id: String
    var firstLoweredID: String {return (id.first.map(String.init)?.lowercased() ?? "") + id.dropFirst()}
    init(raw: String) {
        id = raw.components(separatedBy: .init(charactersIn: ":-"))
            .map {($0.first.map(String.init)?.uppercased() ?? "") + $0.dropFirst()}
            .joined()
    }
}
