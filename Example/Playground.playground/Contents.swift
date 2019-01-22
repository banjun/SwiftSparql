import Cocoa
import SwiftSparql
import BrightFutures
import PlaygroundSupport

enum QueryError: Error {
    case urlSession(Error?)
    case decode(Error)
}

private func fetch<T: Codable>(_ query: Query) -> Future<[T], QueryError> {
    let endpoint = URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!
    return Future<[T], QueryError> { resolve in
        URLSession.shared.dataTask(with: Request(endpoint: endpoint, query: query).request) { data, response, error in
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

struct IdolHeight: Codable {
    var name: String
    var height: Double
    var color: String?
}

class IdolHeightView: NSView {
    let idols: [IdolHeight]
    init(idols: [IdolHeight]) {
        self.idols = idols
        super.init(frame: NSRect(x: 0, y: 0, width: 700, height: 512))
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.cgColor

        idols.enumerated().forEach { i, idol in
            let tf = NSTextField(labelWithString: idol.name)
            tf.font = NSFont.systemFont(ofSize: 16)
            tf.backgroundColor = .clear
            tf.shadow = NSShadow()
            tf.shadow?.shadowBlurRadius = 0.25
            tf.shadow?.shadowColor = .black
            let hexColor = idol.color.flatMap {Int($0, radix: 16)}
            tf.textColor = hexColor.map {NSColor(
                calibratedRed: CGFloat($0 >> 16 & 0xff) / 255,
                green: CGFloat($0 >> 8 & 0xff) / 255,
                blue: CGFloat($0 >> 0 & 0xff) / 255,
                alpha: 1) } ?? .black
            tf.wantsLayer = true
            tf.sizeToFit()
            tf.setFrameOrigin(NSPoint(
                x: CGFloat(i) / CGFloat(idols.count) * frame.width,
                y: -32 + CGFloat(idol.height - 120) / (149 - 120) * frame.height))
            addSubview(tf)
        }
    }
    required init?(coder decoder: NSCoder) {fatalError()}

    override func layout() {
        super.layout()
        subviews.compactMap {$0 as? NSTextField}.forEach {
            $0.layer?.transform = CATransform3DMakeRotation(-.pi * 0.3, 0, 0, 1)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath()
        idols.enumerated().forEach { i, idol in
            let p = NSPoint(x: CGFloat(i) / CGFloat(idols.count) * frame.width,
                            y: CGFloat(idol.height - 120) / (149 - 120) * frame.height - 20)
            if path.isEmpty {
                path.move(to: p)
            } else {
                path.line(to: p)
            }
        }
        NSColor.controlAccentColor.setStroke()
        path.lineWidth = 4
        path.stroke()
    }
}

let schema = PNameNS(value: "schema")
let rdf = PNameNS(value: "rdf")
let imas = PNameNS(value: "imas")

let varS = VarOrTerm.var("?s")
let varName = VarOrTerm.var("?name")
let varHeight = VarOrTerm.var("?height")
let varColor = VarOrTerm.var("?color")

let query = Query(
    prologues: [
        .prefix(schema, IRIRef(value: "http://schema.org/")),
        .prefix(rdf, IRIRef(value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#")),
        .prefix(imas, IRIRef(value: "https://sparql.crssnky.xyz/imasrdf/URIs/imas-schema.ttl#")),
        ],
    select: SelectQuery(
        where: WhereClause(patterns: [
            .triple(varS, .init((rdf, "type")), [.varOrTerm(.term(.iri(.prefixedName(.ln((imas, "Idol"))))))]),
            .triple(varS, .init((imas, "Title")), [.varOrTerm(.term(.rdf(.init(string: "CinderellaGirls", lang: "en"))))]),
            .triple(varS, .init((schema, "name")), [.varOrTerm(varName)]),
            .triple(varS, .init((schema, "height")), [.varOrTerm(varHeight)]),
            .notTriple(.OptionalGraphPattern(.groupGraphPatternSub(GroupGraphPatternSub(patterns: [
                .triple(varS, .init((imas, "Color")), [.varOrTerm(varColor)])])))),
            ]),
        having: [.logical(NumericExpression("?height") <= 149)],
        order: [.var("?height")],
        limit: .limit(100)))

print(Serializer.serialize(query))

fetch(query)
    .onSuccess { (idols: [IdolHeight]) in
        PlaygroundPage.current.liveView = IdolHeightView(idols: idols)
        print(idols)
    }.onFailure {print($0)}


PlaygroundPage.current.needsIndefiniteExecution = true
