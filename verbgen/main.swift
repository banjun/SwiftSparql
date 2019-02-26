import Foundation
import SwiftSparql

guard CommandLine.argc >= 2 else {
    print("usage: \(CommandLine.arguments[0]) (output_dir)")
    exit(1)
}

let outDir: URL
if #available(OSX 10.11, *) {
    outDir = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true,
                 relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true))
} else {
    fatalError()
}

// generate defined verbs with this endpoint
private let endpoint = URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!

TurtleFetcher(urls: [
    URL(string: "https://sparql.crssnky.xyz/imasrdf/URIs/imas-schema.ttl")!,
    URL(string: "https://schema.org/version/latest/schema.ttl")!,
    URL(string: "https://gist.githubusercontent.com/baskaufs/fefa1bfbff14a9efc174/raw/389e4b003ef5cbd6901dd8ab8a692b501bc9370e/foaf.ttl")!, // NOTE: cannot find the official foaf schema in turtle
    ]).fetch { docs in
        VerbGen(target: docs.first!, references: docs, endpoint: endpoint).gen { swiftCode in
            let outFile = outDir.appendingPathComponent("imasparql.swift")
            print("writing swift file to \(outFile)")
            try! swiftCode.data(using: .utf8)!.write(to: outFile)
            exit(0)
        }
}

dispatchMain()
