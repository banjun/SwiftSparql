import Foundation
import SwiftSparql

// FIXME: do not use build time #file and take as input
let projectDir = URL(fileURLWithPath: #file, isDirectory: false).deletingLastPathComponent().deletingLastPathComponent()
let vocabulariesDir = projectDir
    .appendingPathComponent("Example")
    .appendingPathComponent("Vocabularies")
let turtleFile = vocabulariesDir.appendingPathComponent("imas-schema.ttl")
let turtleDoc = try! TurtleDoc(String(contentsOf: turtleFile))
//        NSLog("%@", "turtleDoc = \(String(describing: turtleDoc))")
let swiftCodes = turtleDoc.triples.compactMap {SubjectDescription($0)}.map {$0.swiftCode}
print(swiftCodes.joined(separator: "\n\n"))
