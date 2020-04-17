import Cocoa
import SwiftSparql
import BrightFutures
import PlaygroundSupport

struct IdolHeight: Codable {
    var name: String
    var height: Double
    var color: String?
    var age: String?
}
extension IdolHeight {
    var nsColor: NSColor? {
        guard let hex = (color.flatMap {Int($0, radix: 16)}) else { return nil }
        return NSColor(
            calibratedRed: CGFloat(hex >> 16 & 0xff) / 255,
            green: CGFloat(hex >> 8 & 0xff) / 255,
            blue: CGFloat(hex >> 0 & 0xff) / 255,
            alpha: 1)}
}

class IdolHeightView: NSView {
    let idols: [IdolHeight]
    init(idols: [IdolHeight]) {
        self.idols = idols
        super.init(frame: NSRect(x: 0, y: 0, width: 700, height: 512))
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.cgColor

        idols.enumerated().forEach { i, idol in
            let tf = NSTextField(labelWithString: idol.name + (idol.age.map {" (\($0))"} ?? ""))
            tf.font = NSFont.systemFont(ofSize: 16)
            tf.backgroundColor = .clear
            tf.shadow = NSShadow()
            tf.shadow?.shadowBlurRadius = 0.25
            tf.shadow?.shadowColor = .black
            tf.textColor = idol.nsColor ?? .black
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

let varS = Var("s")
let varName = Var("name")
let varHeight = Var("height")
let varColor = Var("color")
let varAge = Var("age")

let query = SelectQuery(
    where: WhereClause {
        subject(varS)
            .rdfTypeIsImasIdol()
            .imasTitle(is: .literal("CinderellaGirls", lang: "en"))
            .rdfsLabel(is: varName)
            .schemaHeight(is: varHeight)
            .optional { $0
                .imasColor(is: varColor)
                .foafAge(is: varAge)
            }
    },
    having: [.logical(varHeight <= 149)],
    order: [.by(varHeight)],
    limit: 100)

print(Serializer.serialize(query))

Request(endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!, select: query)
    .fetch()
    .onSuccess { (idols: [IdolHeight]) in
        PlaygroundPage.current.liveView = IdolHeightView(idols: idols)
        print(idols)
    }.onFailure {print($0)}


PlaygroundPage.current.needsIndefiniteExecution = true
