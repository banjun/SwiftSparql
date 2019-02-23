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

public extension BuiltInCall {
    static func CONTAINS(v: Var, sub: String) -> BuiltInCall {
        return .CONTAINS(Expression(.STR(v: v)), Expression(stringLiteral: sub))
    }
    static func regex(v: Var, pattern: String) -> BuiltInCall {
        return .regex(Expression(.STR(v: v)), Expression(stringLiteral: pattern), nil)
    }
    static func STR(v: Var) -> BuiltInCall {
        return .STR(Expression(v))
    }
}

public extension OrderCondition {
    static func asc(v: Var) -> OrderCondition {
        return .asc(Expression(v))
    }
    static func desc(v: Var) -> OrderCondition {
        return .desc(Expression(v))
    }
    static func by(_ v: Var) -> OrderCondition {
        return .var(v)
    }
    static func by(_ c: BuiltInCall) -> OrderCondition {
        return .constraint(.builtInCall(c))
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

// MARK: - Triples Builder

public protocol TripleBuilderStateType {}
public protocol TripleBuilderStateIncompleteSubjectType: TripleBuilderStateType {}
public struct TripleBuilderStateIncompleteSubject: TripleBuilderStateIncompleteSubjectType {}
public protocol TripleBuilderStateRDFTypeBoundType: TripleBuilderStateType {
    associatedtype RDFType
}
public struct TripleBuilderStateRDFTypeBound<T: RDFTypeConvertible>: TripleBuilderStateRDFTypeBoundType {
    public typealias RDFType = T
}

public protocol IRIBaseProvider {
    static var base: IRIRef { get }
}

public extension IRIBaseProvider {
    static func rdfType(_ local: String) -> IRIRef {return IRIRef(value: base.value + local)}
    static func verb(_ local: String) -> IRIRef {return IRIRef(value: base.value + local)}
    static func verb(_ local: String) -> PropertyListPathNotEmpty.Verb {
        return .init(IRIRef(value: base.value + local))
    }
}

public protocol RDFTypeConvertible {
    associatedtype Schema: IRIBaseProvider
    static var rdfType: IRIRef { get }
}

public struct TripleBuilder<State: TripleBuilderStateType> {
    public var subject: Var
    public var triples: [GroupGraphPatternSubType]

    public init(subject: Var, triples: [GroupGraphPatternSubType]) {
        self.subject = subject
        self.triples = triples
    }

    static func subject(_ v: Var) -> TripleBuilder<TripleBuilderStateIncompleteSubject> {
        return .init(subject: v, triples: [])
    }

    public init(base: TripleBuilder<State>, appendingVerb verb: PropertyListPathNotEmpty.Verb, value: ObjectListPath) {
        self.init(subject: base.subject, triples: base.triples + [.triple(.var(base.subject), verb, value)])
    }

    func appended(verb: PropertyListPathNotEmpty.Verb, value: ObjectListPath) -> TripleBuilder<State> {
        return .init(base: self, appendingVerb: verb, value: value)
    }
}

public func subject(_ v: Var) -> TripleBuilder<TripleBuilderStateIncompleteSubject> {
    return .subject(v)
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfType<T: RDFTypeConvertible>(is type: T.Type) -> TripleBuilder<TripleBuilderStateRDFTypeBound<T>> {
        let new = appended(verb: RdfSchema.verb("type"), value: [.iriRef(type.rdfType)])
        return .init(subject: subject, triples: new.triples)
    }
}

extension TripleBuilder {
    public func optional(block: (TripleBuilder<State>) -> TripleBuilder<State>) -> TripleBuilder<State> {
        let optionalTriples = block(.init(subject: subject, triples: [])).triples
        return .init(subject: subject, triples: triples + [.notTriple( .OptionalGraphPattern(.groupGraphPatternSub(.init(patterns: optionalTriples))))])
    }

    private func verbPathAlternatives(_ triples: [GroupGraphPatternSubType]) -> PropertyListPathNotEmpty.Verb {
        return triples.compactMap {
            switch $0 {
            case .triple(_, let lv, _): return lv
            default: fatalError("not yet implemented")
            }
        }.reduce(.path([]), |)
    }

    public func alternative(_ block: (TripleBuilder<State>) -> [(RDFLiteral) -> TripleBuilder<State>], is v: RDFLiteral) -> TripleBuilder<State> {
        let alternatives = block(.init(subject: subject, triples: []))
        let pathAlternative = verbPathAlternatives(Array(alternatives.map {$0(v).triples}.joined()))
        return .init(subject: self.subject, triples: self.triples + [.triple(.var(self.subject), pathAlternative, [.literal(v)])])
    }

    public func alternative(_ block: (TripleBuilder<State>) -> [(Var) -> TripleBuilder<State>], is v: Var) -> TripleBuilder<State> {
        let alternatives = block(.init(subject: subject, triples: []))
        let pathAlternative = verbPathAlternatives(Array(alternatives.map {$0(v).triples}.joined()))
        return .init(subject: self.subject, triples: self.triples + [.triple(.var(self.subject), pathAlternative, [.var(v)])])
    }

    // NOTE: filter does not use the subject and thus this may not be right place. (actually independent to TripleBuilder)
    public func filter(_ c: BuiltInCall) -> TripleBuilder<State> {
        return .init(subject: subject, triples: triples + [.filter(c)])
    }

    public func filter(_ c: Constraint) -> TripleBuilder<State> {
        return .init(subject: subject, triples: triples + [.filter(c)])
    }
}


public func | (lhs: PropertyListPathNotEmpty.Verb, rhs: PropertyListPathNotEmpty.Verb) -> PropertyListPathNotEmpty.Verb {
    switch (lhs, rhs) {
    case (.path(let l), .path(let r)): return .path(l | r)
    default: fatalError("not yet implemented")
    }
}
