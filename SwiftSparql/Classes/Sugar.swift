public enum GroupGraphPatternSubType {
    case triple(VarOrTerm, PropertyListPathNotEmpty.Verb, ObjectListPath)
    case notTriple(GraphPatternNotTriples)
}

public extension GroupGraphPatternSubType {
    static func filter(_ c: Constraint) -> GroupGraphPatternSubType {
        return .notTriple(.Filter(c))
    }
    static func filter(_ c: BuiltInCall) -> GroupGraphPatternSubType {
        return .filter(.builtInCall(c))
    }
}

public extension WhereClause {
    public init(patterns: [GroupGraphPatternSubType]) {
        self.init(pattern: .groupGraphPatternSub(.init(patterns: patterns)))
    }
}

public extension GroupGraphPatternSub {
    init(patterns: [GroupGraphPatternSubType]) {
        var intermediates: [(GraphPatternNotTriples?, [TriplesSameSubjectPath])] = []

        patterns.forEach { e in
            switch e {
            case .triple(let t):
                let tssp = TriplesSameSubjectPath.varOrTerm(t.0, .init(verb: t.1, objectListPath: t.2, successors: []))
                var x = intermediates.popLast() ?? (nil, [])
                x.1.append(tssp)
                intermediates.append(x)
            case .notTriple(let nt):
                intermediates.append((nt, []))
            }
        }

        if let first = intermediates.first {
            self.init(
                first: first.0 == nil ? TriplesBlock(first.1) : nil,
                successors: intermediates.dropFirst().compactMap { nt, ts in
                    nt.map {($0, TriplesBlock(ts))}
            })
        } else {
            self.init(first: nil, successors: [])
        }
    }
}

extension TriplesBlock {
    init?(_ groups: [TriplesSameSubjectPath]) {
        guard let head = groups.first else { return nil }
        let tail = Array(groups.dropFirst())
        self.init(triplesSameSubjectPath: head, triplesBlock: .init(TriplesBlock(tail)))
    }
}
