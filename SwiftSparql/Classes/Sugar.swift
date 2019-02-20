public enum GroupGraphPatternSubType {
    case triple(VarOrTerm, PropertyListPathNotEmpty.Verb, ObjectListPath)
    case notTriple(GraphPatternNotTriples)
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
public struct TripleBuilderStateRDFTypeBound<T: ObjectPathConvertible>: TripleBuilderStateRDFTypeBoundType {
    public typealias RDFType = T
}

public protocol ObjectPathConvertible {
    static var objectPath: ObjectPath { get }
}
public struct ImasIdol: ObjectPathConvertible {
    public static var objectPath: ObjectPath {return .varOrTerm(.term(.iri(.prefixedName(.ln((PNameNS(value: "imas"), "Idol"))))))}
}
public struct ImasUnit: ObjectPathConvertible {
    public static var objectPath: ObjectPath {return .varOrTerm(.term(.iri(.prefixedName(.ln((PNameNS(value: "imas"), "Unit"))))))}
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

    func appended(verb: PropertyListPathNotEmpty.Verb, value: ObjectListPath) -> TripleBuilder<State> {
        return .init(subject: subject, triples: triples + [.triple(.var(subject), verb, value)])
    }
}

public func subject(_ v: Var) -> TripleBuilder<TripleBuilderStateIncompleteSubject> {
    return .subject(v)
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    func rdfType<T: ObjectPathConvertible>(is type: T.Type) -> TripleBuilder<TripleBuilderStateRDFTypeBound<T>> {
        let new = appended(verb: .init((PNameNS(value: "rdf"), "type")), value: [type.objectPath])
        return .init(subject: subject, triples: new.triples)
    }

    public func rdfTypeIsImasIdol() -> TripleBuilder<TripleBuilderStateRDFTypeBound<ImasIdol>> {return rdfType(is: ImasIdol.self)}
    public func rdfTypeIsImasUnit() -> TripleBuilder<TripleBuilderStateRDFTypeBound<ImasUnit>> {return rdfType(is: ImasUnit.self)}
}

extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == ImasIdol {
    // MARK: generated functions in form of imas:_

    func nameKana(is value: ObjectListPath) -> TripleBuilder<State> {
        return appended(verb: .init((PNameNS(value: "imas"), "nameKana")), value: value)
    }

    /// 名前よみがな: 名前のよみがなを表すプロパティ
    public func nameKana(is value: RDFLiteral) -> TripleBuilder<State> {
        return nameKana(is: [.varOrTerm(.term(.rdf(value)))])
    }
    /// 名前よみがな: 名前のよみがなを表すプロパティ
    public func nameKana(is v: Var) -> TripleBuilder<State> {
        return nameKana(is: [.varOrTerm(.var(v))])
    }

    func title(is value: ObjectListPath) -> TripleBuilder<State> {
        return appended(verb: .init((PNameNS(value: "imas"), "Title")), value: value)
    }

    ///
    public func title(is value: RDFLiteral) -> TripleBuilder<State> {
        return title(is: [.varOrTerm(.term(.rdf(value)))])
    }
    ///
    public func title(is v: Var) -> TripleBuilder<State> {
        return title(is: [.varOrTerm(.var(v))])
    }

    func color(is value: ObjectListPath) -> TripleBuilder<State> {
        return appended(verb: .init((PNameNS(value: "imas"), "Color")), value: value)
    }

    ///
    public func color(is value: RDFLiteral) -> TripleBuilder<State> {
        return color(is: [.varOrTerm(.term(.rdf(value)))])
    }
    ///
    public func color(is v: Var) -> TripleBuilder<State> {
        return color(is: [.varOrTerm(.var(v))])
    }

    // MARK: generated functions in form of schema:_

    func schemaHeight(is value: ObjectListPath) -> TripleBuilder<State> {
        return .init(subject: subject, triples: triples + [.triple(
            .var(subject),
            .init((PNameNS(value: "schema"), "height")),
            value)])
    }

    public func schemaHeight(is v: Var) -> TripleBuilder<State> {
        return schemaHeight(is: [.varOrTerm(.var(v))])
    }
}


public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == ImasUnit {
    // MARK: generated functions in form of schema:_
    
    /// member: A member of an Organization or a ProgramMembership. Organizations can be members of organizations; ProgramMembership is typically for individuals.
    func schemaMember(is value: RDFLiteral) -> TripleBuilder<State> {
        return .init(subject: subject, triples: triples + [.triple(
            .var(subject),
            .init((PNameNS(value: "schema"), "member")),
            [.varOrTerm(.term(.rdf(value)))])])
    }
}
