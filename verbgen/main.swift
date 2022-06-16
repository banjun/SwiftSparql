import Foundation
import SwiftSparql
import BrightFutures

guard CommandLine.argc >= 2 else {
    print("usage: \(CommandLine.arguments[0]) (output_dir)")
    exit(1)
}

let outDir: URL
if #available(macOS 10.11, *) {
    outDir = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true,
                 relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true))
} else {
    fatalError()
}

/// generate defined verbs from turtle urls, with specified endpoint
@Sendable @available(macOS 10.15, *)
func fetchAndGenCode(endpoint: URL, additionalDirectives: [IRIBaseProvider] = [], urls: [URL], generatedFilename: String) async {
    let docs = await TurtleFetcher(urls: urls).fetch()
    let swiftCode = await VerbGen(target: docs.first!, references: docs, endpoint: endpoint).gen(additionalDirectives: additionalDirectives)
    let outFile = outDir.appendingPathComponent(generatedFilename)
    print("writing swift file to \(outFile)")
    try! swiftCode.data(using: .utf8)!.write(to: outFile)
}

if #available(macOS 10.15, *) {
    Task {
        _ = await [
            fetchAndGenCode(
                endpoint: URL(string: "https://prismdb.takanakahiko.me/sparql")!,
                additionalDirectives: [
                    // NOTE: all prefixes should be resolved to short prefix forms
                    IRIBaseProvider(name: PNameNS(value: "prism"), iri: IRIRef(value: "https://prismdb.takanakahiko.me/prism-schema.ttl#")),
                    IRIBaseProvider(name: PNameNS(value: "rdf"), iri: IRIRef(value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#")),
                    IRIBaseProvider(name: PNameNS(value: "rdfs"), iri: IRIRef(value: "http://www.w3.org/2000/01/rdf-schema#")),
                ],
                urls: [
                    URL(string: "https://prismdb.takanakahiko.me/prism-schema.ttl")!,
                    URL(string: "https://www.w3.org/2000/01/rdf-schema")!,
                    URL(string: "https://www.w3.org/1999/02/22-rdf-syntax-ns")!,
                ],
                generatedFilename: "prismdb.swift"),
            fetchAndGenCode(
                endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!,
                urls: [
                    URL(string: "https://sparql.crssnky.xyz/imasrdf/URIs/imas-schema.ttl")!,
                    URL(string: "https://schema.org/version/latest/schemaorg-current-https.ttl")!,
                    URL(string: "https://www.w3.org/2000/01/rdf-schema")!,
                    URL(string: "https://www.w3.org/1999/02/22-rdf-syntax-ns")!,
                    URL(string: "https://gist.githubusercontent.com/baskaufs/fefa1bfbff14a9efc174/raw/389e4b003ef5cbd6901dd8ab8a692b501bc9370e/foaf.ttl")!, // NOTE: cannot find the official foaf schema in turtle
                ],
                generatedFilename: "imasparql.swift"),
            fetchAndGenCode(
                endpoint: URL(string: "https://vlueprint.org/sparql")!,
                urls: [
                    URL(string: "https://raw.githubusercontent.com/vlueprint/vlueprint/master/sparql-endpoint/toLoad/schema.ttl")!,
                    URL(string: "https://www.w3.org/2000/01/rdf-schema")!,
                    URL(string: "https://www.w3.org/1999/02/22-rdf-syntax-ns")!,
                ],
                generatedFilename: "vlueprint.swift"),
        ]
        exit(0)
    }
    dispatchMain()
} else {
    exit(1)
}
