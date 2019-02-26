struct CamelIdentifier {
    var id: String
    var firstLoweredID: String {return (id.first?.lowercased() ?? "") + id.dropFirst()}
    init(raw: String) {
        id = raw.components(separatedBy: .init(charactersIn: ":-"))
            .map {($0.first?.uppercased() ?? "") + $0.dropFirst()}
            .joined()
    }
}
