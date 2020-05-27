# SwiftSparql

![CI](https://github.com/banjun/SwiftSparql/workflows/CI/badge.svg)
![verbgen](https://github.com/banjun/SwiftSparql/workflows/verbgen/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/SwiftSparql.svg?style=flat)](https://cocoapods.org/pods/SwiftSparql)
[![License](https://img.shields.io/cocoapods/l/SwiftSparql.svg?style=flat)](https://cocoapods.org/pods/SwiftSparql)
[![Platform](https://img.shields.io/cocoapods/p/SwiftSparql.svg?style=flat)](https://cocoapods.org/pods/SwiftSparql)

SwiftSparql includes:

* SPARQL query generator
* SPARQL response parser (SPARQL 1.1 Query Results JSON Format (application/sparql-results+json))
* Swift code generator `verbgen` for significant verbs in an endpoint

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### CocoaPods

SwiftSparql is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftSparql'
```

### Swift Package Manager

Step by step:

```
mkdir sparql
cd sparql
swift package init --type executable
```

Edit generated `Package.swift`:

```swift
// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sparql",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/banjun/SwiftSparql", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "sparql",
            dependencies: ["SwiftSparql"])
    ]
)
```

```
swift package generate-xcodeproj
open sparql.xcodeproj
```

Edit `main.swift` & Run with macOS destination.

```swift
import Foundation
import SwiftSparql
:
```

For example:

```swift
// construct query
let q = SelectQuery(
    where: WhereClause(patterns:
        subject(Var("s"))
            .rdfTypeIsImasIdol() // in the followings, verbs for this type can be auto-completed
            .imasType(is: "Cu")
            .foafAge(is: 17)
            .schemaName(is: Var("name"))
            .schemaHeight(is: Var("height"))
            .triples),
    order: [.desc(v: Var("height"))])

// capture results by Codable type
struct Idol: Codable {
    var name: String
    var height: Double
}

// request query to the endpoint URL
Request(endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!, select: q)
    .fetch()
    .onSuccess { (idols: [Idol]) in // Codable type annotation for being decoded by fetch()
        idols.forEach { idol in
            print("\(idol.name) (\(idol.height)cm)")
        }
        exit(0)
    }.onFailure {fatalError(String(describing: $0))}

dispatchMain()
```

## Special Thanks

im@sparql dataset & its endpoint: <https://github.com/imas/imasparql>

## License

SwiftSparql is available under the MIT license. See the LICENSE file for more info.
