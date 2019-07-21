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

private enum _RdfSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#")}
}

public protocol RDFTypeConvertible {
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
        let new = appended(verb: _RdfSchema.verb("type"), value: [.iriRef(type.rdfType)])
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
