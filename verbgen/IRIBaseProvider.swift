import SwiftSparql

struct IRIBaseProvider {
    let name: PNameNS
    let iri: IRIRef
    var typeName: String {return CamelIdentifier(raw: name.value!).id + "Schema"}
}
